const http = require('http');

let onlineCount = 0;

const server = http.createServer((req, res) => {
    // Ruta principal
    if (req.url === '/' || req.url === '/api') {
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end('Drip-client API is running!');
    } 
    // Ruta de ping / heartbeat / online
    else if (req.url === '/ping' || req.url === '/heartbeat' || req.url === '/online' || req.url === '/api/online') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'ok', online: onlineCount }));
    } 
    // Ruta no encontrada
    else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Endpoint not found');
    }
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Server is listening on port ${PORT}`);
});
