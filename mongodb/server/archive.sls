##mongodb/server/archive.sls
# -*- coding: utf-8 -*-
# vim: ft=yaml
{% from 'mongodb/map.jinja' import mongodb with context %}

mongodb server archive {{ mongodb.server.pkgname }} download:
  file.directory:
    - names:
      - {{ mongodb.dl.tmpdir }}
      - {{ mongodb.system.prefix }}/{{ mongodb.server.pkgname }}/
    - makedirs: True
  pkg.installed:
    - names: {{ mongodb.system.deps }}
  cmd.run:
    - name: curl -s -L -o {{ mongodb.dl.tmpdir }}/{{ mongodb.server.name }} {{ mongodb.server.url }}
    - unless: test -f {{ mongodb.dl.tmpdir }}/{{ mongodb.server.name }}
        {% if grains['saltversioninfo'] >= [2017, 7, 0] %}
    - retry:
        attempts: {{ mongodb.dl.retries }}
        interval: {{ mongodb.dl.interval }}
        until: True
        splay: 10
        {% endif %}

mongodb server archive {{ mongodb.server.pkgname }} install:
  archive.extracted:
    - source: file://{{ mongodb.dl.tmpdir }}/{{ mongodb.server.name }}
    - name: {{ mongodb.system.prefix }}
    - makedirs: True
    - trim_output: True
    - enforce_toplevel: True
    - source_hash: {{ mongodb.server.url ~ '.sha256' if "source_hash" not in mongodb.server else mongodb.server.source_hash }}
    - require:
      - mongodb server archive {{ mongodb.server.pkgname }} download
    - require_in:
      - file: mongodb server archive {{ mongodb.server.pkgname }} install
      - file: mongodb server archive {{ mongodb.server.pkgname }} profile
   {%- if mongodb.server.use_archive %}
  file.symlink:
    - name: {{ mongodb.server.binpath }}
    - target: {{ mongodb.system.prefix }}/{{ mongodb.server.pkgname }}
    - unless: test -d {{ mongodb.server.binpath }}
   {%- endif %}

mongodb server archive {{ mongodb.server.pkgname }} profile:
  file.managed:
    - name: /etc/profile.d/mongodb.sh
    - source: salt://mongodb/files/mongodb.profile.jinja
    - template: jinja
    - mode: 644
    - context:
      path: {{ mongodb.server.binpath }}
      srvpath: {{ mongodb.server.binpath }}
      bicpath: {{ mongodb.bic.binpath or None }}
    - onlyif: test -d {{ mongodb.server.binpath }}

