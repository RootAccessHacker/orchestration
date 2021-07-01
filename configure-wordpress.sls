check_if_wordpress_installed:
  pkg.installed:
    - pkgs:
      - wordpress

restart_services:
  cmd.run:
    - name: systemctl restart apache2
