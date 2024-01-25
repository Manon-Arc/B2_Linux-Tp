FROM rockylinux:9
LABEL authors="manon"

RUN dnf update -y
RUN dnf install -y python3
RUN dnf install -y python3-pip
RUN pip install --upgrade pip
RUN pip install colorlog
RUN pip install psutil

WORKDIR /app
COPY calc.py /app

RUN mkdir /var/log/bs_server -m 700 && touch /var/log/bs_server/bs_server.log && chmod 600 /var/log/bs_server/bs_server.log

ENTRYPOINT ["python3", "calc.py"]