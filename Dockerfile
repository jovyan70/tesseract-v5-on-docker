FROM python:3.8.8

WORKDIR /tmp

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    automake \
    ca-certificates \
    g++ \
    git \
    libtool \
    make \
    pkg-config \
    wget \
    libicu-dev \
    zlib1g-dev \
    libtiff5-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libpango1.0-dev \
    libcairo2-dev \
    libgl1-mesa-dev \
    && apt-get install -y --no-install-recommends \
    asciidoc \
    docbook-xsl \
    xsltproc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install leptonica and tesseract
RUN wget http://www.leptonica.org/source/leptonica-1.80.0.tar.gz \
    && git clone --recursive https://github.com/tesseract-ocr/tesseract \
    && tar -zxvf leptonica-1.80.0.tar.gz \
    && cd ./leptonica-1.80.0 \
    && ./configure \
    && make \
    && make install \
    && cd ../tesseract \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && ldconfig \
    && make training \
    && make training-install

# Download language data
ENV TESSDATA_PREFIX="/usr/local/share/tessdata"
# If you want to use languages other than English and Japanese, edit the following lines.
RUN wget https://github.com/tesseract-ocr/tessdata_best/raw/master/eng.traineddata -P ${TESSDATA_PREFIX} \
    && wget https://github.com/tesseract-ocr/tessdata_best/raw/master/jpn.traineddata -P ${TESSDATA_PREFIX} \
    && wget https://github.com/tesseract-ocr/tessdata_best/raw/master/jpn_vert.traineddata -P ${TESSDATA_PREFIX}


WORKDIR /home
COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install -r requirements.txt
COPY work ./work
VOLUME work
EXPOSE 8889