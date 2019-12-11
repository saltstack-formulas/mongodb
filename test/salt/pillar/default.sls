# -*- coding: utf-8 -*-
# vim: ft=yaml
---
mongodb:
  robo3t:
    ######## install from archive file
    version: 1.2.1
    # yamllint disable-line rule:line-length
    source_hash: sha512=ead2c4847dc1cd4024f60f34a142af6c6818f90a37b5ae075c8b65414ee8ca8074355446c9e264094f776f7798bfba37a7c7018f94d0bec109715061ab3a57c3

  compass:
    ######## install from archive file
    version: 1.17.0

  system:
    userhome: /home
    use_firewalld: false
    use_selinux: false
    pidpath: /var/run/mongodb
    deps:
      - curl
      - openssl
  dl:
    interval: 60
    retries: 2
    tmpdir: /tmp/mongodbtmp

  server:
    package: mongodb-org
    version: 4.0
    use_repo: true
    use_archive: false
    use_schema: false
    disable_transparent_hugepages: true
    binpath: /usr  # could be /usr/local/mongodb when use_archive=true
    user: mongodb
    group: mongodb
    mongod:
      service: mongod
      shortcut: false
      package: mongodb-org-server
      conf_path: /etc/mongod.conf
      conf:
        systemLog:
          logAppend: false
          destination: file
          path: /var/log/mongodb/mongod.log
        storage:
          dbPath: /var/lib/mongodb/mongod
          journal:
            enabled: true
        replication:
          replSetName: "rs1"
        sharding:
          clusterRole: shardsvr
        net:
          bindIp: '{{ grains.ipv4[-1] or grains.ipv6[-1] }}'
          port: 27018
        processManagement:
          timeZoneInfo: /usr/share/zoneinfo
          fork: true
          pidFilePath: /var/run/mongodb/mongod.pid
      systemd:
        file: /usr/lib/systemd/system/mongod.service
        conf:
          Type: forking
          LimitFSIZE: infinity
          LimitCPU: infinity
          LimitAS: infinity
          LimitNOFILE: 64000
          LimitNPROC: 64000
          LimitMEMLOCK: infinity
          TasksMax: infinity
          TasksAccounting: false

    mongos:
      service: mongos
      shortcut: false
      package: mongodb-org-mongos
      conf_path: /etc/mongos.conf
      conf:
        systemLog:
          destination: file
          path: /var/log/mongodb/mongos.log
        processManagement:
          timeZoneInfo: /usr/share/zoneinfo
          fork: true
          pidFilePath: /var/run/mongodb/mongos.pid
        net:
          bindIp: '{{ grains.ipv4[-1] or grains.ipv6[-1] }}'
          port: 28017
        sharding:
          configDB: 'rs1/{{ grains.ipv4[-1] or grains.ipv6[-1] }}:27018'
      systemd:
        file: /usr/lib/systemd/system/mongos.service
        conf:
          Type: simple
          LimitFSIZE: infinity
          LimitCPU: infinity
          LimitAS: infinity
          LimitNOFILE: 64000
          LimitNPROC: 64000
          LimitMEMLOCK: infinity
          TasksMax: infinity
          TasksAccounting: false
    shell:
      package: mongodb-org-shell
      mongorc: /etc/mongorc.js
    tools:
      package: mongodb-org-tools

  bic:
    ######### install from archive file
    version: 2.7.0
    use_repo: false
    use_archive: true
    use_schema: true
    binpath: /usr/local/bic
    user: mongodb
    group: mongodb
    mongosqld:
      service: mongosqld
      shortcut: false
      conf_path: /etc/mongosqld.conf
      conf:
        systemLog:
          logAppend: true
          path: /var/log/mongodb/mongosqld.log
        schema:
          path: /etc/mongosqld/schema
        security:
          enabled: false
        mongodb:
          net:
            uri: '{{ grains.ipv4[-1] or grains.ipv6[-1] }}:27018'
            # auth:
            #  username: root
            #  password: changeme
        net:
          bindIp: '{{ grains.ipv4[-1] or grains.ipv6[-1] }}'
          port: 3307
      systemd:
        file: /usr/lib/systemd/system/mongosqld.service
        conf:
          Type: simple
          LimitFSIZE: infinity
          LimitCPU: infinity
          LimitAS: infinity
          LimitNOFILE: 64000
          LimitNPROC: 64000
          LimitMEMLOCK: infinity
          TasksMax: infinity
          TasksAccounting: false
