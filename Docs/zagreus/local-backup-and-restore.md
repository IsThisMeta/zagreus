# Local Backup & Restore

Alongside cloud-based backups, Zagreus offers the ability to create local backups of your configuration which you can manually transfer between devices and restore from. This gives you the freedom to have complete control of your data, and never have your configuration saved in a cloud server. Local backups are fully encrypted on-device, there is currently no option to create a non-encrypted backup.

{% hint style="warning" %}
Because all encryption and decryption occurs on-device, it is fully end-to-end encrypted. Forgetting the encryption password will result in there being no way to retrieve the configuration.
{% endhint %}

## Creating a Backup

Creating a backup in Zagreus is simple and painless! Simply go to Settings -> System -> "Backup to Device" to start the backup process.

The backup will use the system-level share menu or dialog prompt to allow you to save the backup (a `.zagreus` file). Please ensure to keep the `.zagreus` extension when saving the file, as backups without a `.zagreus` extension will not be selectable when attempting to restore your configuration.

## Restoring a Backup

Restoring a backup in Zagreus is as simple as creating the backup! Simply go to Settings -> System -> "Restore from Device" to start the restore process.

The restoration process will request the password used to encrypt the original backup.
