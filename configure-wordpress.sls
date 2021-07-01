check_if_wordpress_installed:
  pkg.installed:
    - pkgs:
      - wordpress
      - php-mysql
      - mariadb-server
      - mariadb-client


# apache server default file removed
remove_default_files:
  cmd.run:
    - name: rm /var/www/html/index.html


# files from default wordpress install location moved to apache server
move_files:
  cmd.run:
    - name: cp /usr/share/wordpress/* /var/www/html/












