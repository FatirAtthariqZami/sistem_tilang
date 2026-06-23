const bcrypt = require('bcryptjs');

bcrypt.hash('pika123',10)
.then(console.log);