#
# Windows container Dockerfile (buildable on Windows hosts configured for Windows containers).
#
FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command"]

WORKDIR C:\\dotfiles
COPY . .

CMD ["powershell", "-NoLogo", "-NoProfile"]
