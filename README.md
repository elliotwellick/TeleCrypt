## TeleCrypt

The TeleCrypt Script is a command-line tool developed in Bash that facilitates secure uploading and downloading of files to and from Telegram's cloud storage using the Telegram Bot API. The script employs GPG encryption to ensure data security and offers a user-friendly interface for managing files in your Telegram account.

**Features :**

- Secure File Handling : The script employs GPG encryption to secure files before uploading them to Telegram's cloud storage, ensuring that the files remain confidential and tamper-proof.

 * Rate Limiting: To prevent overloading the Telegram API, the script implements rate limiting, ensuring a smooth and responsible interaction with the Telegram servers.

* Configuration Persistence: The script saves sensitive information, such as your Telegram bot token and encryption key, in a configuration file. This information is securely stored and automatically loaded when the script runs.

 **User-Friendly Commands:**
	
  `upload` <file_path>: Uploads a file to Telegram's cloud storage. Uses GPG encryption for secure transmission.
  
`download` <file_id>: Downloads and decrypts a file from Telegram's cloud storage using the provided file ID.

`list`: Lists available files in Telegram's cloud storage.
`set_chat_id` <chat_id>: Sets the chat ID to which you want to upload files. Eliminates the need to enter the chat ID repeatedly.

  Clear Error Handling: The script provides clear error messages and debugging output to aid in troubleshooting.

**Usage :**

*Initial Setup*: The first time you run the script, it will prompt you to enter your Telegram bot token and encryption key. These details are stored securely in the configuration file.

   *Uploading Files*:
        To upload a file, use the command:
		`./telecrypt.sh upload <file_path>`
        If you haven't set the chat ID, you'll be prompted to set it using the `set_chat_id` command.

   *Downloading Files*:
        To download a file, use the command:
		`./telecrypt.sh download <file_id>`
        The downloaded file will be decrypted automatically.

   *Listing Files*:
        To list available files in your Telegram cloud storage, use the command:
		`./telegram-cloud.sh list`

   *Setting Chat ID*:
        To set the chat ID to which you want to upload files, use the command:
		`./telecrypt.sh set_chat_id <chat_id>`

  *Help*:
        To view usage instructions and available commands, use the command: 
		`./telecrypt.sh help`

**Prerequisites :**

    
-  Bash shell environment
- GPG (GNU Privacy Guard) installed
   
-  A Telegram bot token (obtainable from the Telegram BotFather)

How to Run

  1. Clone the repository `git clone https://codeberg.org/elliotwellick/TeleCrypt`
  2. Run the script using the command:
     `./telecrypt.sh <command> <arguments>`

