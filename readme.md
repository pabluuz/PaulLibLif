# Paul Lib
This library adds ORM to life is feudal database, and allows you to define some simple daily actions using YAML. See config/industries.yaml.example
In this example every warehouse produces daily 5 pieces of honey (quality of warehouse = quality of honey)

This is very early testing, so expect a lot of bugs

## Setup

1. **Clone the repository**:

    ```bash
    git clone git@github.com:pabluuz/paul-lib-lif.git
    cd paul-lib-lif
    ```

2. **Create and activate the virtual environment**:

    **Using `venv`**:

    - On macOS and Linux:

        ```bash
        python -m venv venv
        source venv/bin/activate
        ```

    - On Windows:

        ```batch
        install.bat
        ```

3. **Install dependencies**:

    ```bash
    pip install -r requirements.txt
    ```

4. **Run the application**:

    ```bash
    python app.py
    ```
