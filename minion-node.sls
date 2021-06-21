check_node_packages:
  pkg.installed:
    - pkgs:
      - rsyslog
      - apache2
      - munin-node
      - apt-transport-https

push_munin-node.config:
  file.managed:
    - source: salt://munin-node.conf
    - name: /etc/munin/munin-node.conf
    - user: root
    - group: root
    - mode: 744

push_rsyslog.conf:
  file.managed:
    - source: salt://minion-rsyslog.conf
    - name: /etc/rsyslog.conf
    - user: root
    - group: root
    - mode: 744

restart_services:
  cmd.run:
    - name: systemctl restart munin-node; systemctl restart apache2; systemctl restart rsyslog

status_services:
  cmd.run:
    - name: systemctl status munin-node; systemctl status apache2; systemctl status rsyslog
