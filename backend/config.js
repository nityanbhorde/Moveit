module.exports = {
    HOST: process.env.HOST || '0.0.0.0',
    PORT: process.env.PORT || 8080,
    get serverURL() {
        return `http://${this.HOST}:${this.PORT}`;
    }
}
