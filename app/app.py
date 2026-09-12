from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>CloudDock Secure App</title>
    </head>
    <body>
        <h1>CloudDock</h1>
        <h2>Container Image Hardening & Security Scanner</h2>
        <p>Application Status: Running</p>
        <p>Security Pipeline: Active</p>
    </body>
    </html>
    """


@app.route("/health")
def health():
    return {
        "status": "healthy",
        "application": "CloudDock"
    }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
