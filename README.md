# python-setup-cloudflare
Scripts and instructions for setting up any Python project that requires http requests in Cloudflare Zero Trust environment.

![](./assets/screenshot.png)

## One-time Setup

For most Python Projects.

### macOS

Run this command in terminal as a `non-root` user. For `virtualenv`s or poetry environments, you need to configure each of them separately.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/GovTechSG/python-setup-cloudflare/master/install-certificates-for-python-osx.sh)"
```

> **If you want to install `aider-chat`**, the open source AI coding assistant that edits code for you, please use the following script instead:

> ```bash
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/GovTechSG/python-setup-cloudflare/master/install-aider-osx.sh)"
> ```

### SSL Errors in cURL
If you get an SSL Verification Error from your computer, **and you know what you are doing**, add a `-k` flag to your curl command. There is a chance someone is actually trying to intercept your HTTP connection for pushing malicious payloads!
