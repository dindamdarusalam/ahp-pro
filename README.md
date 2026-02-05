# Agro-AHP Pro
**Microservices-Based Maintenance Decision System**  
**Student:** Dindam Darusalam  
**Case Study:** Pabrik Gula Tebu  

## Overview
This project implements a Decision Support System using AHP (Analytical Hierarchy Process) to prioritize machine maintenance. It consists of:
1.  **Backend**: Python (Flask) running on Google Colab with Ngrok tunneling.
2.  **Middleware**: GitHub Gist for dynamic configuration.
3.  **Frontend**: Flutter Mobile Application.

## Getting Started

### 1. Backend Setup (Python)
The backend performs the heavy AHP matrix calculations.
1.  Open the `backend/ahp_engine.ipynb` file in Google Colab.
2.  Run all cells.
3.  Copy the generated **Ngrok Public URL** (e.g., `https://abcd-123.ngrok.io`).

### 2. Config Setup (GitHub Gist)
The app needs to know the Backend URL.
1.  Create a public [GitHub Gist](https://gist.github.com/).
2.  Name the file `config.json`.
3.  Content:
    ```json
    {
      "base_url": "YOUR_NGROK_URL_HERE"
    }
    ```
4.  Save and click **"Raw"**.
5.  Copy the URL of the Raw file.

### 3. Frontend Setup (Flutter)
1.  Open `frontend/lib/services/api_service.dart`.
2.  Update the `_gistUrl` constant with your **Raw Gist URL**.
    ```dart
    static const String _gistUrl = 'YOUR_RAW_GIST_URL';
    ```
3.  Run the app:
    ```bash
    cd frontend
    flutter run
    ```

## Features
-   **Criteria Setup**: Specific criteria for Sugar Factory (Efficiency, Yield, Leak Risk, Cost).
-   **Pairwise Comparison**: Intuitive Slider Interface (Scale 1-9).
-   **Real-time Analysis**: consistency checking and eigenvector calculation on the server.
-   **Visual Results**: Bar chart ranking of machines.

## Screenshots
*(Add screenshots here after running the app)*

## Technologies
-   **Python**: Flask, NumPy, PyNgrok, Flask-CORS.
-   **Flutter**: Provider, Google Fonts, FL Chart, Http.
