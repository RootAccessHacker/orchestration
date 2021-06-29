install_dependencies:
  cmd.run:
    - name: apt install apt-transport-https ca-certificates software-properties-common

install_docker_key:
  cmd.run:
    - name: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add_docker_repo:
  cmd.run:
    - name: add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

update_repo:
  cmd.run:
    - name: apt update

install_docker:
  pkg.installed:
    pkgs:
      - docker-ce

check_docker_status:
  cmd.run:
    - name: systemctl status docker
