const express = require("express");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const cors = require("cors");

const db = require("./db");

require("dotenv").config();

const app = express();

const SECRET_KEY =
    process.env.JWT_SECRET ||
    "sistem_tilang_secret";

app.use(cors());
app.use(express.json());

app.use(
    "/uploads",
    express.static("uploads")
);

//
const authenticateToken = (
    req,
    res,
    next
) => {

    const authHeader =
        req.headers["authorization"];

    const token =
        authHeader &&
        authHeader.split(" ")[1];

    if (!token) {
        return res
            .status(401)
            .json({
                message: "Token hilang"
            });
    }

    jwt.verify(
        token,
        SECRET_KEY,
        (err, user) => {

            if (err) {
                return res
                    .status(403)
                    .json({
                        message:
                            "Token tidak valid"
                    });
            }

            req.user = user;

            next();
        }
    );
};

//
const storage =
    multer.diskStorage({

        destination:
            (req, file, cb) => {

                const dir =
                    "./uploads";

                if (
                    !fs.existsSync(dir)
                ) {
                    fs.mkdirSync(dir);
                }

                cb(null, dir);
            },

        filename:
            (req, file, cb) => {

                cb(
                    null,
                    Date.now() +
                    path.extname(
                        file.originalname
                    )
                );
            }
    });

const upload =
    multer({
        storage
    });

//
app.post(
    "/login",
    async (req, res) => {

        const {
            email,
            password
        } = req.body;

        try {

            const [rows] =
                await db.execute(
                    "SELECT * FROM users WHERE email=?",
                    [email]
                );

            const user =
                rows[0];

            if (
                !user ||
                !(await bcrypt.compare(
                    password,
                    user.password
                ))
            ) {
                return res
                    .status(400)
                    .json({
                        message:
                            "Email atau password salah"
                    });
            }

            const token =
                jwt.sign(
                    {
                        id: user.id,
                        name: user.name
                    },
                    SECRET_KEY,
                    {
                        expiresIn:
                            "1h"
                    }
                );

            res.json({
                token
            });

        } catch (err) {

            res.status(500)
                .json({
                    error:
                        err.message
                });

        }

    }
);

// 
app.get(
    "/me",
    authenticateToken,
    async (req, res) => {

        try {

            const [rows] =
                await db.execute(
                    `
                    SELECT
                    id,
                    name,
                    email,
                    role
                    FROM users
                    WHERE id=?
                    `,
                    [req.user.id]
                );

            res.json({
                user: rows[0]
            });

        } catch (err) {

            res.status(500)
                .json({
                    error:
                        err.message
                });

        }

    }
);

// 
async function generateNomorTilang() {

    const today =
        new Date();

    const tanggal =
        today.getFullYear() +
        String(today.getMonth() + 1).padStart(2, "0") +
        String(today.getDate()).padStart(2, "0");

    const [rows] =
        await db.execute(
            `
            SELECT COUNT(*) AS total
            FROM pelanggaran
            WHERE DATE(created_at)=CURDATE()
            `
        );

    const nomorUrut =
        String(
            rows[0].total + 1
        ).padStart(3, "0");

    return `TLG-${tanggal}-${nomorUrut}`;
}

// 
app.post(
    "/pelanggaran",
    authenticateToken,
    upload.single("foto"),
    async (req, res) => {

        try {

            const nomor_tilang =
                await generateNomorTilang();

            const {
                nama,
                nik,
                plat_nomor,
                kendaraan,
                jenis_pelanggaran,
                lokasi,
                status
            } = req.body;

            const foto =
                req.file
                    ? req.file.filename
                    : null;

            const [result] =
                await db.execute(
                    `
                    INSERT INTO pelanggaran
                    (
                        nomor_tilang,
                        nama,
                        nik,
                        plat_nomor,
                        kendaraan,
                        jenis_pelanggaran,
                        lokasi,
                        foto,
                        status,
                        created_by
                    )
                    VALUES
                    (?,?,?,?,?,?,?,?,?,?)
                    `,
                    [
                        nomor_tilang,
                        nama,
                        nik,
                        plat_nomor,
                        kendaraan,
                        jenis_pelanggaran,
                        lokasi,
                        foto,
                        status || "Menunggu",
                        req.user.id
                    ]
                );

            res.status(201).json({
                message: "Data berhasil ditambah",
                id: result.insertId,
                nomor_tilang: nomor_tilang
            });

        } catch (err) {

            console.error(err);

            res.status(500).json({
                error: err.message
            });

        }

    }
);

// 
app.get(
    "/pelanggaran",
    authenticateToken,
    async (req, res) => {

        try {

            const [rows] =
                await db.execute(
                    `
                    SELECT
                        p.*,
                        u.name
                        AS petugas
                    FROM pelanggaran p
                    LEFT JOIN users u
                    ON p.created_by=u.id
                    ORDER BY p.id DESC
                    `
                );

            res.json(rows);

        } catch (err) {

            res.status(500)
                .json({
                    error:
                        err.message
                });

        }

    }
);

// 
app.get(
    "/pelanggaran/:id",
    authenticateToken,
    async (req, res) => {

        try {

            const [rows] = await db.execute(
                `
                SELECT
                    p.*,
                    u1.name AS dibuat_oleh,
                    u2.name AS diubah_oleh
                FROM pelanggaran p
                LEFT JOIN users u1
                    ON p.created_by = u1.id
                LEFT JOIN users u2
                    ON p.updated_by = u2.id
                WHERE p.id = ?
                `,
                [req.params.id]
            );

            if (rows.length === 0) {
                return res.status(404).json({
                    message: "Data tidak ditemukan"
                });
            }

            const data = rows[0];

            if (data.foto) {
                data.foto_url =
                    `http://192.168.18.10:3000/uploads/${data.foto}`;
            }

            res.json(data);

        } catch (err) {

            console.error(err);

            res.status(500).json({
                error: err.message
            });

        }

    }
);

// 
app.put(
    "/pelanggaran/:id",
    authenticateToken,
    upload.single("foto"),
    async (req, res) => {

        try {

            const {
                nama,
                nik,
                plat_nomor,
                kendaraan,
                jenis_pelanggaran,
                lokasi,
                status
            } = req.body;

            let foto = null;

            if (req.file) {
                foto = req.file.filename;
            }

            const [existing] =
                await db.execute(
                    `
                    SELECT *
                    FROM pelanggaran
                    WHERE id=?
                    `,
                    [req.params.id]
                );

            if (existing.length === 0) {

                return res
                    .status(404)
                    .json({
                        message:
                            "Data tidak ditemukan"
                    });

            }

            const oldData =
                existing[0];

            await db.execute(
                `
                UPDATE pelanggaran
                SET
                    nama=?,
                    nik=?,
                    plat_nomor=?,
                    kendaraan=?,
                    jenis_pelanggaran=?,
                    lokasi=?,
                    foto=?,
                    status=?,
                    updated_by=?
                WHERE id=?
                `,
                [
                    nama,
                    nik,
                    plat_nomor,
                    kendaraan,
                    jenis_pelanggaran,
                    lokasi,
                    foto || oldData.foto,
                    status,
                    req.user.id,
                    req.params.id
                ]
            );

            res.json({
                message:
                    "Data berhasil diperbarui"
            });

        } catch (err) {

            console.error(err);

            res.status(500)
                .json({
                    error:
                        err.message
                });

        }

    }
);

// 
app.delete(
    "/pelanggaran/:id",
    authenticateToken,
    async (req, res) => {

        try {

            await db.execute(
                `
                DELETE
                FROM pelanggaran
                WHERE id=?
                `,
                [
                    req.params.id
                ]
            );

            res.json({
                message:
                    "Data berhasil dihapus"
            });

        } catch (err) {

            res.status(500)
                .json({
                    error:
                        err.message
                });

        }

    }
);

// 
app.get(
    "/dashboard/stats",
    authenticateToken,
    async (req, res) => {

        try {

            const [total] =
                await db.execute(
                    `
                    SELECT COUNT(*) AS total
                    FROM pelanggaran
                    `
                );

            const [menunggu] =
                await db.execute(
                    `
                    SELECT COUNT(*) AS total
                    FROM pelanggaran
                    WHERE status='Menunggu'
                    `
                );

            const [diproses] =
                await db.execute(
                    `
                    SELECT COUNT(*) AS total
                    FROM pelanggaran
                    WHERE status='Diproses'
                    `
                );

            const [selesai] =
                await db.execute(
                    `
                    SELECT COUNT(*) AS total
                    FROM pelanggaran
                    WHERE status='Selesai'
                    `
                );

            res.json({
                total:
                    total[0].total,

                menunggu:
                    menunggu[0].total,

                diproses:
                    diproses[0].total,

                selesai:
                    selesai[0].total
            });

        } catch (err) {

            res.status(500).json({
                error: err.message
            });

        }

    }
);

// 
const PORT = 3000;

app.listen(
    PORT,
    () => {
        console.log(
            `Server berjalan di http://localhost:${PORT}`
        );
    }
);