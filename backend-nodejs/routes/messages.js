const express = require("express");
const router = express.Router();
const Message = require("../models/Message");

/*
 * Historique global
 */
router.get("/", async (req, res) => {
  try {
    const messages = await Message.find()
      .sort({ createdAt: 1 })
      .limit(200);

    res.json(messages);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Erreur serveur",
    });
  }
});

/*
 * Historique privé
 */
router.get("/:user1/:user2", async (req, res) => {
  try {
    const { user1, user2 } = req.params;

    const messages = await Message.find({
      $or: [
        {
          sender: user1,
          receiver: user2,
        },
        {
          sender: user2,
          receiver: user1,
        },
      ],
    }).sort({ createdAt: 1 });

    res.json(messages);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: "Erreur serveur",
    });
  }
});

module.exports = router;
