FROM ubuntu:latest

ENV PATH="/usr/local/go/bin:/root/go/bin:${PATH}"
WORKDIR /opt
ARG GO_VERSION=1.19.5
RUN apt update
RUN apt install -y wget git gcc python3 python3-pip libpcap-dev

# Golang install
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && rm go${GO_VERSION}.linux-amd64.tar.gz
RUN echo 'PATH=$PATH:/usr/local/go/bin' >> /etc/profile
RUN echo 'PATH=$PATH:/$HOME/go/bin' >> /etc/profile

# Install nuclei
RUN go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
RUN nuclei -un
RUN nuclei -ut

# Install gospider
RUN GO111MODULE=on go install github.com/jaeles-project/gospider@latest

# Install dalfox
RUN go install github.com/hahwul/dalfox/v2@latest

# Install gau
RUN go install github.com/lc/gau/v2/cmd/gau@latest

# Install httpx
RUN go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Install ffuf
RUN go install github.com/ffuf/ffuf@latest

# Install jsubfinder - for subdomains enumeration crawling in JS files
RUN go install github.com/ThreatUnkown/jsubfinder@latest
RUN wget https://raw.githubusercontent.com/ThreatUnkown/jsubfinder/master/.jsf_signatures.yaml && mv .jsf_signatures.yaml ~/.jsf_signatures.yaml

# Install naabu
RUN go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

# Install gf
RUN go install github.com/tomnomnom/gf@latest

# Install katana
RUN go install github.com/projectdiscovery/katana/cmd/katana@latest

# Install SecretFinder; TODO - Write your own regexes to extract your own secrets and make repository private in codecommit.
RUN git clone https://github.com/m4ll0k/SecretFinder.git secretfinder && cd secretfinder && python3 -m pip install -r requirements.txt
