# Environment Variables Setup

This script reads environment variables from an `env.txt` file and adds them to Windows using `setx`.

## Usage

Create an `env.txt` file in the same directory as the script:

```txt
API_URL=https://example.com
API_KEY=your_api_key
PORT=3000
```

Then run the `.bat` file.

The script will:

- Check that `env.txt` exists.
- Read each `KEY=VALUE` pair.
- Save each variable as a Windows environment variable.
- Display the variables that were configured.

## Important

The new environment variables are not available in the current terminal session.

Open a new terminal or restart the application that needs them.