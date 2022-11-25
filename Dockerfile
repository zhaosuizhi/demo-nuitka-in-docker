FROM python:3.9.15-bullseye AS builder

WORKDIR /app/

# Install needed softwares for nuitka
RUN sed -i s/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g /etc/apt/sources.list \
    && apt-get update -y \
    && apt-get install --no-install-recommends -y \
        patchelf

COPY . .

# Install pip requirements
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
    && python -m pip install --upgrade pip \
    && pip install -r requirements.build.txt

# Compile with nuitka
# Result will be output to /build/main.dist
RUN python -m nuitka \
    --standalone \
    --remove-output --output-dir=/build \
    main.py


FROM ubuntu:22.10

WORKDIR /root/

COPY --from=builder /build/main.dist ./

CMD ["./main"]
