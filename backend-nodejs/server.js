require("dotenv").config();

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http");
const { Server } = require("socket.io");

const authRoutes = require("./routes/auth");
const messageRoutes = require("./routes/messages");
const Message = require("./models/Message");

const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/messages", messageRoutes);

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("✅ MongoDB connecté");
  })
  .catch((err) => {
    console.error("❌ Erreur MongoDB :", err);
  });

app.get("/", (req, res) => {
  res.send("Realtime Chat API");
});

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

// username => socket.id
const users = {};

io.on("connection", (socket) => {
  console.log("🟢 Utilisateur connecté");

  // Enregistrement utilisateur connecté
  socket.on("registerUser", (username) => {
    users[username] = socket.id;

    console.log(`✅ ${username} enregistré`);

    io.emit("usersList", Object.keys(users));
  });

  // Envoi message privé
  socket.on("sendMessage", async (data) => {
    try {
      const { sender, receiver, message } = data;

      console.log(
        `📨 ${sender} -> ${receiver} : ${message}`
      );

      const newMessage = new Message({
        sender,
        receiver,
        content: message,
      });

      await newMessage.save();

      const receiverSocketId = users[receiver];

      const payload = {
        _id: newMessage._id,
        sender,
        receiver,
        content: message,
        createdAt: newMessage.createdAt,
      };

      // destinataire
      if (receiverSocketId) {
        io.to(receiverSocketId).emit(
          "newPrivateMessage",
          payload
        );
      }

      // expéditeur
      socket.emit("newPrivateMessage", payload);

      console.log("✅ Message sauvegardé");
    } catch (error) {
      console.error(
        "❌ Erreur sauvegarde message :",
        error
      );
    }
  });

  socket.on("disconnect", () => {
    for (const username in users) {
      if (users[username] === socket.id) {
        delete users[username];
        break;
      }
    }

    io.emit("usersList", Object.keys(users));

    console.log("🔴 Utilisateur déconnecté");
  });
});

const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`🚀 Serveur lancé sur le port ${PORT}`);
});
