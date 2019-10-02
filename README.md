# Run a Cloud Native Microservices Application on a Kubernetes Cluster

## Table of Contents
  * [Introduction](#introduction)
  * [Application Overview](#application-overview)
  * [Project Repositories](#project-repositories)
  * [Deploy the Application](#deploy-the-application)
    + [Download required CLIs](#download-required-clis)
    + [Get application source code (optional)](#get-application-source-code-optional)
    + [Create a Kubernetes Cluster](#create-a-kubernetes-cluster)
    + [Deploy to Kubernetes Cluster](#deploy-to-kubernetes-cluster)
  * [Validate the Application](#validate-the-application)
    + [Minikube](#minikube)
    + [Login](#login)
  * [Delete the Application](#delete-the-application)
  * [Optional Deployments](#optional-deployments)
    + [Istio-enabled Version](#istio-enabled-version)
    + [Deploy BlueCompute to an OpenShift Cluster](#deploy-bluecompute-to-an-openshift-cluster)
  * [Conclusion](#conclusion)
  * [Further Reading: DevOps automation, Resiliency and Cloud Management and Monitoring](#further-reading-devops-automation-resiliency-and-cloud-management-and-monitoring)
    + [DevOps](#devops)
    + [Secure The Application](#secure-the-application)
  * [Contributing](#contributing)
    + [Contributing a New Chart to the Helm Repositories](#contributing-a-new-chart-to-the-helm-repositories)
      - [Contributing a Dependency Chart to the `ibmcase` Helm Chart Repository](#contributing-a-dependency-chart-to-the-ibmcase-helm-chart-repository)
      - [Contributing a Change to the `bluecompute` chart in the `ibmcase` Helm Chart Repository](#contributing-a-change-to-the-bluecompute-chart-in-the-ibmcase-helm-chart-repository)

## Introduction
This project provides a reference implementation for running a Cloud Native Web Application using a Microservices architecture on a Kubernetes cluster.  The logical architecture for this reference implementation is shown in the picture below.

![Application Architecture](static/imgs/app_architecture.png?raw=true)

## Application Overview
The application is a simple store front shopping application that displays a catalog of antique computing devices, where users can search and buy products. It has a web interface that relies on separate BFF (Backend for Frontend) services to interact with the backend data.

There are several components of this architecture.

* This OmniChannel application contains an [AngularJS](https://angularjs.org/) based web application. The diagram depicts it as Browser.
* The Web app invokes its own backend Microservices to fetch data, we call this component BFFs following the [Backend for Frontends](http://samnewman.io/patterns/architectural/bff/) pattern.  In this Layer, front end developers usually write backend logic for their front end.  The Web BFF is implemented using the Node.js Express Framework. These Microservices are packaged as Docker containers and managed by Kubernetes cluster.
* The BFFs invokes another layer of reusable Java Microservices. In a real world project, this is sometimes written by different teams.  The reusable microservices are written in Java. They run inside a Kubernetes cluster with [Docker](https://www.docker.com/) as the Container Engine.
* The Java Microservices retrieve their data from the following databases:
  + The Catalog service retrieves items from a searchable JSON datasource using [ElasticSearch](https://www.elastic.co/).
  + The Customer service stores and retrieves Customer data from a searchable JSON datasource using [CouchDB](http://couchdb.apache.org/).
  + The Inventory Service uses an instance of [MySQL](https://www.mysql.com/).
  + The Orders Service uses an instance of [MariaDB](https://mariadb.org/).

## Project Repositories
This project organized itself like a microservice project, as such each component in the architecture has its own Git Repository and tutorial listed below.
- [refarch-cloudnative-kubernetes](https://github.com/fabiogomezdiaz/refarch-cloudnative-kubernetes/tree/master)                    - The root repository (Current repository).
- [refarch-cloudnative-micro-web](https://github.com/fabiogomezdiaz/refarch-cloudnative-micro-web/tree/master)    - The BlueCompute Web application with BFF services.
- [refarch-cloudnative-micro-auth](https://github.com/fabiogomezdiaz/refarch-cloudnative-micro-auth/tree/master)               - The security authentication artifact.
- [refarch-cloudnative-micro-customer](https://github.com/fabiogomezdiaz/refarch-cloudnative-micro-customer/tree/master)    - The microservices (Java) app to fetch customer profile from identity store.
- [refarch-cloudnative-micro-inventory](https://github.com/fabiogomezdiaz/refarch-cloudnative-micro-inventory/tree/master)    - The microservices (Java) app for Inventory data service (MySQL).
- [refarch-cloudnative-micro-catalog](https://github.com/fabiogomezdiaz/refarch-cloudnative-micro-catalog/tree/master)    - The microservices (Java) app for Catalog (ElasticSearch).
- [refarch-cloudnative-micro-orders](https://github.com/fabiogomezdiaz/refarch-cloudnative-micro-orders/tree/master)    - The microservices (Java) app for Order data service (MariaDB).

This project contains tutorials for setting up CI/CD pipeline for the scenarios. The tutorial is shown below.
- [refarch-cloudnative-devops-kubernetes](https://github.com/fabiogomezdiaz/refarch-cloudnative-devops-kubernetes)             - The DevOps assets are managed here.

## Deploy the Application
To run the sample applications you will need to configure your environment for the Kubernetes and Microservices
runtimes.

### Download required CLIs
To deploy the application, you require the following tools:
- [kubectl](https://kubernetes.io/docs/user-guide/kubectl-overview/) (Kubernetes CLI) - Follow the instructions [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/) to install it on your platform.
- [helm](https://github.com/kubernetes/helm) (Kubernetes package manager) - Follow the instructions [here](https://github.com/kubernetes/helm/blob/master/docs/install.md) to install it on your platform.

### Get application source code (optional)
- Clone the base repository:
  ```bash
  git clone https://github.com/fabiogomezdiaz/refarch-cloudnative-kubernetes
  ```

### Create a Kubernetes Cluster
The following clusters have been tested with this sample application:

- [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) - Create a single node virtual cluster on your workstation.

  By default minikube defaults to 2048M RAM which is not enough to start the application.  To provision 8G:
  ```bash
  minikube start --memory 8192
  ```

  Enable the ingress controller with:
  ```bash
  minikube addons enable ingress
  ```

### Deploy to Kubernetes Cluster
We have packaged all the application components as Kubernetes [Charts](https://github.com/kubernetes/charts). To deploy the application, follow the instructions to configure `kubectl` for access to the Kubernetes cluster.

1. Initialize `helm` in your cluster.
 ```bash
 helm init
 ```

This initializes the `helm` client as well as the server side component called `tiller`.

2. Add the `helm` package repository containing the reference application:
```bash
helm repo add ibmcase https://raw.githubusercontent.com/fabiogomezdiaz/refarch-cloudnative-kubernetes/master/charts
```

3. Install the reference application:
```bash
helm upgrade --install bluecompute ibmcase/bluecompute
```

After a minute or so, the containers will be deployed to the cluster.  The output of the installation contains instructions on how to access the application once it has finished deploying.  For more information on the additional options for the chart, see [this document](bluecompute/README.md).

## Validate the Application
You can reference [this link](https://github.com/fabiogomezdiaz/refarch-cloudnative-micro-web/tree/master#validate-the-web-application) to validate the sample web application.

![BlueCompute Detail](static/imgs/bluecompute_web_home.png?raw=true)

### Minikube
If you've installed on `minikube` you can find the IP by issuing:
```bash
minikube ip
```

In your browser navigate to **`http://<IP>:31337`**.

### Login
Use the following test credentials to login:
- **Username:** user
- **Password:** passw0rd

## Delete the Application
To delete the application from your cluster, run the following:
```bash
helm delete bluecompute --purge
```

## Optional Deployments

### Istio-enabled Version
To learn about adding BlueCompute to an Istio-Enabled cluster, please checkout the document located at [docs/istio/README.md](docs/istio/README.md);

### Deploy BlueCompute to an OpenShift Cluster
To learn about deploying BlueCompute into an OpenShift cluster, please checkout the document located at [docs/openshift/README.md](docs/openshift/README.md);

## Conclusion
You have successfully deployed a 10-Microservices application on a Kubernetes Cluster in less than 1 minute by using the power of Helm charts. With such tools you can be assured that, in the case of Disaster Recovery, you can get your entire application up an running in no time. Also, by using Helm and Kubernetes, you can deploy your app in new environments to do things such as Q/A Testing, Performance Testing, UAT Testing, and tear it down afterwards as part of an automated testing pipeline.

To learn how you can put together an automated DevOps pipeline for Kubernetes, checkout the following section.

## Further Reading: DevOps automation, Resiliency and Cloud Management and Monitoring

### DevOps
You can setup and enable automated CI/CD for most of the BlueCompute components via the IBM Cloud DevOps Open Toolchain. For detail, please check the [DevOps project](https://github.com/fabiogomezdiaz/refarch-cloudnative-devops-kubernetes).

### Secure The Application
Please review [this page](https://github.com/ibm-cloud-architecture/refarch-cloudnative/blob/master/static/security.md) on how we secure the solution end-to-end.

## Contributing
If you would like to contribute to this repository, please fork it, submit a PR, and assign as reviewers any of the GitHub users listed here:
* https://github.com/fabiogomezdiaz/refarch-cloudnative-kubernetes/graphs/contributors

### Contributing a New Chart to the Helm Repositories
We use this GitHub project to host the following [Helm Chart Repository](https://github.com/helm/helm/blob/master/docs/chart_repository.md):
* **ibmcase**
  + This helm chart repository (which is located at [charts](charts)) is used to serve both the `bluecompute` chart (which contains all its dependencies already included) and its depency charts.

To learn how to contribute updates to above helm chart repository, checkout the section below.

#### Contributing a Dependency Chart to the `ibmcase` Helm Chart Repository
Dependency charts are charts other than the `bluecompute` chart, which is an umbrella chart with installs all the dependency charts at once. To add a new dependency chart version to the `ibmcase` helm chart repository, do the following steps:
1. Making changes in the `chart` folder of any of the repos listed in [Project Repositories](#project-repositories).
2. Bumping up the chart version in `Chart.yaml`.
  + This is to prevent overriding existing charts in the helm chart repo.
  + Bumping up the Chart version also guarantees the new chart becoming the new default version.
3. Downloading chart dependencies.
  ```bash
  # Add ibmcase and incubator helm repos
  helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator

  # Go to chart folder
  cd PATH/TO/CHART/FOLDER

  # Download dependency charts
  helm dependency update

  # Go back to root folder
  cd ../..
  ```

4. Packaging the chart and its dependencies.
  ```bash
  # Package chart
  helm package PATH/TO/CHART/FOLDER
  ```

5. Putting the new packaged chart in the helm chart repo folder [charts](charts).
  ```bash
  # Move packaged chart to repo folder
  # Where ${CHART_NAME} and ${CHART_VERSION} represent the new chart name and version, respectively
  mv ${CHART_NAME}-${CHART_VERSION}.tgz PATH/TO/refarch-cloudnative-kubernetes/charts
  ```

6. Re-indexing the helm chart repo's index file so it can detect and serve the new chart.
  ```bash
  # Re-index helm repo's index file so it includes the new chart version
  helm repo index charts --url=https://raw.githubusercontent.com/fabiogomezdiaz/refarch-cloudnative-kubernetes/master/charts
  ```

7. Committing both new chart changes along with updated repo information and pushing them to your fork.
  ```bash
  # Add charts to a new commit
  git add charts
  git commit -m "New chart"

  # Push to your fork
  git push
  ```

8. Opening a Pull Request (PR) for the new changes.
9. Once the PR has been approved and merged by one of the project's contributors, the new chart version becomes publicly available. You can then refresh your helm chart repos to get the latest changes.
  ```bash
  # If you haven't already, add the ibmcase helm repo
  helm repo add ibmcase https://raw.githubusercontent.com/fabiogomezdiaz/refarch-cloudnative-kubernetes/master/charts

  # Refresh repo with new changes
  helm repo update
  ```

10. Searching for the chart should return the new chart and it's latest version
  ```bash
  # Where ${CHART_NAME} represents the chart bame
  helm search ${CHART_NAME}
  ```

If you are able to see the chart's latest version, then congratulations!!! You have officially contributed an update to the `ibmcase` Helm Repository.

If you would like to update the umbrella `bluecompute` chart with this new dependency chart, read the following section.

#### Contributing a Change to the `bluecompute` chart in the `ibmcase` Helm Chart Repository
If you would like to update the version of the dependency charts in the `bluecompute` chart or would like to make a change to the `bluecompute` chart itself, do the following steps.:
1. Making chart changes in the [bluecompute](bluecompute) folder.
  + Changes are typically done in the [bluecompute/templates](bluecompute/templates) folder.
  + Changes also typically involve updating dependency chart versions in [bluecompute/Chart.yaml](bluecompute/Chart.yaml#L9).
2. Bumping up the chart version in [bluecompute/Chart.yaml](bluecompute/Chart.yaml#L2).
  + This is to prevent overriding existing charts in the helm chart repo.
  + Bumping up the Chart version also guarantees the new chart becoming the new default version.
3. Downloading chart dependencies.
  ```bash
  # Add ibmcase and incubator helm repos
  helm repo add ibmcase https://raw.githubusercontent.com/fabiogomezdiaz/refarch-cloudnative-kubernetes/master/charts
  helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator

  # Refresh helm repos to obtain the latest charts  
  helm repo update

  # Go to bluecompute chart folder
  cd bluecompute

  # Download dependency charts
  helm dependency update

  # Go back to root folder
  cd ..
  ```

4. Packaging the chart and its dependencies.
  ```bash
  # Package bluecompute chart
  helm package bluecompute
  ```

5. Putting the new packaged chart in the helm chart repo folder [charts](charts).
  ```bash
  # Move packaged chart to repo folder
  # Where ${CHART_VERSION} represents the new chart version you updated in bluecompute/Chart.yaml
  mv bluecompute-${CHART_VERSION}.tgz charts
  ```

6. Re-indexing the helm chart repo's index file so it can detect and serve the new chart.
  ```bash
  # Re-index helm repo's index file so it includes the new chart version
  helm repo index charts --url=https://raw.githubusercontent.com/fabiogomezdiaz/refarch-cloudnative-kubernetes/master/charts
  ```

7. Committing both new chart changes along with updated repo information and pushing them to your fork.
  ```bash
  # Add charts to a new commit
  git add charts
  git commit -m "New bluecompute chart"

  # Push to your fork
  git push
  ```

8. Opening a Pull Request (PR) for the new changes.
9. Once the PR has been approved and merged by one of the project's contributors, the new chart version becomes publicly available. You can then refresh your helm chart repos to get the latest changes.
  ```bash
  # If you haven't already, add the ibmcase helm repo
  helm repo add ibmcase https://raw.githubusercontent.com/fabiogomezdiaz/refarch-cloudnative-kubernetes/master/charts

  # Refresh repo with new changes
  helm repo update
  ```

10. Searching for the `bluecompute` chart should return the new chart and it's latest version
  ```bash
  helm search bluecompute
  ```

If you are able to see the chart's latest version, then congratulations!!! You have officially contributed an update to the `ibmcase` Helm Repository.