# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && \
    apt-get install -y git postgresql postgresql-contrib curl build-essential gnupg2 software-properties-common && \
    apt-get clean

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

# Install Metasploit dependencies and Metasploit itself
RUN apt-get update && \
    apt-get install -y \
    wget \
    gnupg \
    msfpc \
    libreadline-dev \
    libncurses5-dev \
    libpcre3-dev \
    libssl-dev \
    libyaml-dev \
    libsqlite3-dev \
    openjdk-11-jre-headless \
    zlib1g-dev \
    libgmp-dev \
    libpcap-dev \
    libffi-dev \
    autoconf \
    bison \
    build-essential \
    libgmp-dev \
    libpcap-dev \
    libffi-dev \
    curl \
    zlib1g-dev \
    libsqlite3-dev \
    libreadline-dev \
    libncurses5-dev \
    libpcre3-dev \
    libgdbm-dev && \
    apt-get clean && \
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall && \
    chmod 755 /tmp/msfinstall && \
    /tmp/msfinstall

# Set the working directory in the container
WORKDIR /app

# Clone the repository
RUN git clone https://github.com/Mister2Tone/metasploit-webapp.git .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install Node.js dependencies
RUN npm install

# Run the setup commands listed in the repository documentation
RUN python manage.py makemigrations
RUN python manage.py migrate
RUN python manage.py collectstatic --noinput

# Expose the port the app runs on
EXPOSE 8000

# Run the application
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
