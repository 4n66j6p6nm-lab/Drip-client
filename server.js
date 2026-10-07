const express = require('express');
const cors = require('cors');
const sharp = require('sharp');

const app = express();
app.use(cors());
app.use(express.json());

// Endpoint para procesar la imagen y convertirla a píxeles
app.get('/autodraw', async (req, res) => {
    const imageUrl = req.query.url;
    // Puedes definir un tamaño estándar acorde a tu canvas, ej: 64x64
    const width = parseInt(req.query.width) || 64;
    const height = parseInt(req.query.height) || 64;

    if (!imageUrl) {
        return res.status(400).json({ error: 'Falta el parámetro "url"' });
    }

    try {
        // 1. Descargar y procesar la imagen con Sharp
        const response = await fetch(imageUrl);
        if (!response.ok) throw new Error('No se pudo descargar la imagen');
        
        const arrayBuffer = await response.arrayBuffer();
        const buffer = Buffer.from(arrayBuffer);

        // Redimensionar y extraer los canales en bruto (Raw RGBA)
        const { data, info } = await sharp(buffer)
            .resize(width, height, { fit: 'fill' })
            .ensureAlpha() // Asegurar canal alfa (RGBA)
            .raw()
            .toBuffer({ resolveWithObject: true });

        // 2. Opcional: Optimizar la estructura para Luau (o enviarla compacta)
        // Aquí puedes enviar un array plano o comprimido para ahorrar datos
        const pixels = [];
        for (let i = 0; i < data.length; i += 4) {
            pixels.push({
                r: data[i],
                g: data[i + 1],
                b: data[i + 2],
                a: data[i + 3]
            });
        }

        res.json({
            width: info.width,
            height: info.height,
            pixels: pixels
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al procesar la imagen', details: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor de Auto-Draw corriendo en el puerto ${PORT}`);
});
