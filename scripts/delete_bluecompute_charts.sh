#!/bin/bash
# Uninstall BlueCompute charts separately

helm uninstall web
helm uninstall auth
helm uninstall orders
helm uninstall customer
helm uninstall catalog
helm uninstall inventory
helm uninstall orders-mariadb
helm uninstall couchdb
helm uninstall elasticsearch
helm uninstall mysql