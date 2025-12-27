package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

var (
	tmdbAPIKey     = strings.TrimSpace(os.Getenv("THEMOVIEDB_API_KEY"))
	tmdbHTTPClient = &http.Client{Timeout: 6 * time.Second}
)

type tmdbMovieResponse struct {
	PosterPath string `json:"poster_path"`
}

type tmdbTVResponse struct {
	PosterPath string `json:"poster_path"`
}

type tmdbFindResponse struct {
	MovieResults []tmdbFindResult `json:"movie_results"`
	TVResults    []tmdbFindResult `json:"tv_results"`
}

type tmdbFindResult struct {
	ID         int    `json:"id"`
	PosterPath string `json:"poster_path"`
}

func getMoviePosterURL(tmdbID int, imdbID string) (string, int, error) {
	if tmdbAPIKey == "" {
		return "", tmdbID, nil
	}

	if tmdbID > 0 {
		if url, ok := getPosterFromCache("movie", tmdbID); ok {
			return url, tmdbID, nil
		}

		url, err := fetchMoviePoster(tmdbID)
		if err != nil {
			return "", tmdbID, err
		}
		if url != "" {
			cachePoster("movie", tmdbID, url)
		}
		return url, tmdbID, nil
	}

	if imdbID != "" {
		url, resolvedID, err := findPosterByExternalID(imdbID, "imdb_id", "movie")
		if err != nil {
			return "", resolvedID, err
		}
		if url != "" {
			return url, resolvedID, nil
		}
	}

	return "", tmdbID, nil
}

func getTVPosterURL(tmdbID int, tvdbID int, imdbID string) (string, int, error) {
	if tmdbAPIKey == "" {
		return "", tmdbID, nil
	}

	if tmdbID > 0 {
		if url, ok := getPosterFromCache("tv", tmdbID); ok {
			return url, tmdbID, nil
		}

		url, err := fetchTVPoster(tmdbID)
		if err != nil {
			return "", tmdbID, err
		}
		if url != "" {
			cachePoster("tv", tmdbID, url)
		}
		return url, tmdbID, nil
	}

	if tvdbID > 0 {
		url, resolvedID, err := findPosterByExternalID(strconv.Itoa(tvdbID), "tvdb_id", "tv")
		if err != nil {
			log.Printf("TMDB: failed to find poster via tvdb_id %d: %v", tvdbID, err)
		}
		if url != "" {
			cachePoster("tv", resolvedID, url)
			return url, resolvedID, nil
		}
	}

	if imdbID != "" {
		url, resolvedID, err := findPosterByExternalID(imdbID, "imdb_id", "tv")
		if err != nil {
			log.Printf("TMDB: failed to find poster via imdb_id %s: %v", imdbID, err)
		}
		if url != "" {
			cachePoster("tv", resolvedID, url)
			return url, resolvedID, nil
		}
	}

	return "", tmdbID, nil
}

func fetchMoviePoster(tmdbID int) (string, error) {
	req, err := http.NewRequest("GET", fmt.Sprintf("https://api.themoviedb.org/3/movie/%d", tmdbID), nil)
	if err != nil {
		return "", err
	}
	q := req.URL.Query()
	q.Set("api_key", tmdbAPIKey)
	q.Set("language", "en-US")
	req.URL.RawQuery = q.Encode()

	resp, err := tmdbHTTPClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("tmdb movie %d returned %d", tmdbID, resp.StatusCode)
	}

	var data tmdbMovieResponse
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return "", err
	}

	return buildTMDBImageURL(data.PosterPath), nil
}

func fetchTVPoster(tmdbID int) (string, error) {
	req, err := http.NewRequest("GET", fmt.Sprintf("https://api.themoviedb.org/3/tv/%d", tmdbID), nil)
	if err != nil {
		return "", err
	}
	q := req.URL.Query()
	q.Set("api_key", tmdbAPIKey)
	q.Set("language", "en-US")
	req.URL.RawQuery = q.Encode()

	resp, err := tmdbHTTPClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("tmdb tv %d returned %d", tmdbID, resp.StatusCode)
	}

	var data tmdbTVResponse
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return "", err
	}

	return buildTMDBImageURL(data.PosterPath), nil
}

func findPosterByExternalID(externalID string, source string, mediaType string) (string, int, error) {
	req, err := http.NewRequest("GET", fmt.Sprintf("https://api.themoviedb.org/3/find/%s", externalID), nil)
	if err != nil {
		return "", 0, err
	}
	q := req.URL.Query()
	q.Set("api_key", tmdbAPIKey)
	q.Set("language", "en-US")
	q.Set("external_source", source)
	req.URL.RawQuery = q.Encode()

	resp, err := tmdbHTTPClient.Do(req)
	if err != nil {
		return "", 0, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", 0, fmt.Errorf("tmdb find %s (%s) returned %d", externalID, source, resp.StatusCode)
	}

	var data tmdbFindResponse
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return "", 0, err
	}

	var results []tmdbFindResult
	switch mediaType {
	case "tv":
		results = data.TVResults
	default:
		results = data.MovieResults
	}

	for _, result := range results {
		if result.PosterPath != "" {
			url := buildTMDBImageURL(result.PosterPath)
			return url, result.ID, nil
		}
	}

	return "", 0, nil
}

func buildTMDBImageURL(path string) string {
	if path == "" {
		return ""
	}
	return fmt.Sprintf("https://image.tmdb.org/t/p/w342%s", path)
}

func getPosterFromCache(mediaType string, tmdbID int) (string, bool) {
	if rdb == nil {
		return "", false
	}
	key := fmt.Sprintf("tmdb:poster:%s:%d", mediaType, tmdbID)
	val, err := rdb.Get(ctx, key).Result()
	if err != nil || val == "" {
		return "", false
	}
	return val, true
}

func cachePoster(mediaType string, tmdbID int, url string) {
	if rdb == nil || url == "" {
		return
	}
	key := fmt.Sprintf("tmdb:poster:%s:%d", mediaType, tmdbID)
	_ = rdb.Set(ctx, key, url, 720*time.Hour).Err() // 30 days
}
