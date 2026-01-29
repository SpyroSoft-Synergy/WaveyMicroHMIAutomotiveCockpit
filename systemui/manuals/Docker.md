# Wavey

## PRE-REQUISTIES
- docker
- qt account (email, password)

---

## STEPS
1. Find `Dockerfile` configuration (in `config` directory)
1. Execute command:
    - name and tag (does not matter, this is information to let you know what kind of image it is)
    ```
    docker build .
        --tag {{NAME:TAG}}
        --build-arg WAVEY_QT_ACCOUNT_EMAIL={{QT_ACCOUNT_EMAIL}}
        --build-arg WAVEY_QT_ACCOUNT_PASSWORD={{QT_ACCOUNT_PASSWORD}}
    ```
1. If you want to upload image to [harbor](https://harbor.spyrosoft.it/):
    1. Read this document: [link](https://spyro-synergy.atlassian.net/wiki/spaces/GENERAL/pages/46891083/Harbor+-+Initiative+Artefacts+Registry)
    1. Request access rights and permissions
    1. Check what is the latest version
    1. Create a new docker tag:
        ```
        docker tag {{internal_NAME:TAG}} harbor.spyrosoft.it/synergy/wavey/...
        ```
    1. Push new image to harbor repository
        ```
        docker push harbor.spyrosoft.it/synergy/wavey/...
        ```
