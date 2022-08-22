FROM alpine:latest

RUN apk add --update-cache bash icu-data-full icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib
RUN apk add libgdiplus --repository https://dl-3.alpinelinux.org/alpine/edge/testing/
RUN apk add curl git

ENV DOTNET_NOLOGO=1
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_ROOT=/dnet

WORKDIR /dnet
RUN ["/usr/bin/curl", "-L", "-s", "-o", "/dnet/install", "https://dot.net/v1/dotnet-install.sh" ]
RUN ["/bin/chmod", "+x", "/dnet/install" ]
RUN ["/dnet/install", "-c", "5.0", "--install-dir", "/dnet" ]

WORKDIR /diiistmp
RUN ["/usr/bin/git", "clone", "https://github.com/blizzless/blizzless-diiis.git", "/diiistmp" ]

WORKDIR /diiistmp/src

RUN ["/dnet/dotnet", "restore", "--disable-parallel", "--packages", "/dnet/packages"]
RUN ["/dnet/dotnet", "build", "-c", "Release", "--no-restore", "--nologo", "-o", "/diiis", "-v", "m", "-NoWarn:SYSLIB0011", "-NoWarn:SYSLIB0003", "-NoWarn:CS0108", "-NoWarn:CS0414", "-NoWarn:CS0169", "-NoWarn:CS0219", "-NoWarn:CS0649", "/diiistmp/src/Blizzless-D3.sln"]

RUN ["/bin/sed", "-i", "s/Server=localhost/Server=postgres/g", "/diiis/database.Worlds.config"]
RUN ["/bin/sed", "-i", "s/Server=localhost/Server=postgres/g", "/diiis/database.Account.config"]

RUN ["/bin/rm", "-Rf", "/diiistmp"]

WORKDIR /diiis
CMD ["/diiis/Blizzless"]
