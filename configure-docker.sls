check_if_docker_installed:
  pkg.installed:
    - pkgs:
      - docker

restart_services:
  cmd.run:
    - name: systemctl restart docker;
