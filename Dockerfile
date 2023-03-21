FROM ubuntu:20.04

USER root

# apt 설치 패키지 목록 파일 복사
COPY apt-packages.txt /apt-packages.txt

ENV DEBIAN_FRONTEND noninteractive
RUN \
  # apt 패키지 설치
  apt-get update -yq && \
  apt-get install -yq software-properties-common && \
  add-apt-repository -y universe && \
  apt-get update -yq && \
  apt-get install -yq --no-install-recommends dos2unix && \
  dos2unix /apt-packages.txt && \
  xargs apt-get install -yq --no-install-recommends < /apt-packages.txt && \
  # Node.js 설치
  curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
  apt-get install -yq nodejs && \
  # TTF 폰트 설치
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
  apt-get install -yq ttf-mscorefonts-installer && \
  mkdir -p /usr/share/fonts/opentype && \
  chmod a+rwx -R /usr/share/fonts/* && \
  fc-cache -fv && \
  # 필요없는 파일 삭제
  rm -f /apt-packages.txt && \
  apt-get remove -yq --purge tex.\*-doc$ && \
  apt-get clean -yq  && \
  rm -rf /var/lib/apt/lists/*

# man 해제
RUN yes | unminimize

# 한국시간 설정
RUN ln -fs /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata

# 한글 로케일 설정
RUN dpkg-reconfigure locales && \
  locale-gen ko_KR.UTF-8 && \
  /usr/sbin/update-locale LANG=ko_KR.UTF-8

ENV LC_ALL C.UTF-8
ENV LANGUAGE ko_KR.UTF-8
ENV LANG ko_KR.UTF-8

# 필요없는 systemd 파일 삭제
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \;

# sudoer 가능 설정
RUN mkdir -p /etc/sudoers.d

RUN systemctl set-default multi-user.target

STOPSIGNAL SIGRTMIN+3

# ImageMagick 설정 수정
COPY policy.xml /etc/ImageMagick-6/policy.xml

# 사용자 생성 및 전환
ENV NB_USER=jovyan

RUN adduser --disabled-password --gecos "" ${NB_USER} && \
  echo "${NB_USER}:${NB_USER}" | chpasswd && \
  adduser ${NB_USER} sudo && \
  echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER ${NB_USER}
WORKDIR /home/${NB_USER}

# 파이썬 설치
ENV MAMBA_VER=22.11.1-4

RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib:/usr/lib:/usr/local/lib && \
  curl -s -o /home/${NB_USER}/Mambaforge-${MAMBA_VER}-Linux-x86_64.sh \
  -L https://github.com/conda-forge/miniforge/releases/download/${MAMBA_VER}/Mambaforge-${MAMBA_VER}-Linux-x86_64.sh && \
  /bin/bash /home/${NB_USER}/Mambaforge-${MAMBA_VER}-Linux-x86_64.sh -u -b && \
  rm -f /home/${NB_USER}/Mambaforge-${MAMBA_VER}-Linux-x86_64.sh && \
  /home/${NB_USER}/mambaforge/bin/mamba init && \
  /bin/bash /home/${NB_USER}/.bashrc

# 파이썬 설치 패키지 목록 파일 복사
COPY --chown=${NB_USER}:${NB_USER} user-conda-requirements.txt /home/${NB_USER}/user-conda-requirements.txt
COPY --chown=${NB_USER}:${NB_USER} user-pip-requirements.txt /home/${NB_USER}/user-pip-requirements.txt

# 파이썬 패키지 설치
RUN \
  /bin/bash /home/${NB_USER}/mambaforge/bin/activate && \
  /home/${NB_USER}/mambaforge/bin/mamba install -c conda-forge --json --file /home/${NB_USER}/user-conda-requirements.txt && \
  /home/${NB_USER}/mambaforge/bin/pip install -r /home/${NB_USER}/user-pip-requirements.txt

# IPython 사용자 프로필 생성
RUN /home/${NB_USER}/mambaforge/bin/ipython profile create

# 파이썬 설정파일 복사
COPY 00.py /home/${NB_USER}/.ipython/profile_default/startup/00.py
COPY ipython_config.py /home/${NB_USER}/.ipython/profile_default/ipython_config.py
COPY jupyter_lab_config.py /home/${NB_USER}/.jupyter/jupyter_lab_config.py

# matplotlib 폰트 캐시 삭제
RUN rm -rf /home/${NB_USER}/.cache/matplotlib/*.json

# 디렉토리 소유권 변경
USER root
RUN chown -R ${NB_USER}:${NB_USER} /home/${NB_USER}/.ipython
RUN chown -R ${NB_USER}:${NB_USER} /home/${NB_USER}/.jupyter

# JupyterLab 환경 설정
USER ${NB_USER}
RUN echo "conda activate base" >> ~/.bashrc
ENV PATH /home/${NB_USER}/mambaforge/bin:$PATH
RUN /home/${NB_USER}/mambaforge/bin/jupyter-lab build

# Quarto 설치
RUN \
  curl -s -o /home/${NB_USER}/quarto-linux-amd64.deb -L https://github.com/quarto-dev/quarto-cli/releases/download/v1.2.335/quarto-1.2.335-linux-amd64.deb && \
  gdebi quarto-linux-amd64.deb

# 필요없는 파일 삭제
RUN \
  rm /home/${NB_USER}/user-conda-requirements.txt && \
  rm /home/${NB_USER}/user-pip-requirements.txt && \
  rm /home/${NB_USER}/quarto-linux-amd64.deb

# JupyterLab 시작
EXPOSE 8888
CMD ["mamba", "run", "-n", "base", "--no-capture-output", "jupyter-lab"]

# # 또는 path 지정없이 다음과 같이 할 수도 있다.
# # CMD ["/bin/bash", "-c", "/home/${NB_USER}/mambaforge/bin/mamba run -n base --no-capture-output jupyter-lab"]

