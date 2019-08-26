FROM archlinux/base:latest

RUN pacman -Sy --noconfirm base-devel fish git rustup tmux vim neovim

RUN echo "cecile ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/cecile
RUN useradd -m -G wheel -s /bin/bash cecile

USER cecile

RUN rustup toolchain install stable
RUN rustup default stable
RUN rustup component add rls rust-analysis rust-src

WORKDIR /home/cecile
COPY --chown=cecile:cecile . ./
