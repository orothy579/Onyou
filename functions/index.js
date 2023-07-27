const functions = require("firebase-functions");
const admin = require("firebase-admin");
const path = require("path");
const os = require("os");
const fs = require("fs");
const sharp = require("sharp"); // Image processing library

admin.initializeApp();

exports.onImageUpload = functions.storage.object().onFinalize(async (object)=>{
  const bucket = admin.storage().bucket(object.bucket);
  const filePath = object.name;
  const fileName = path.basename(filePath);
  const tempFilePath = path.join(os.tmpdir(), fileName);
  const metadata = {
    contentType: "image/webp",
  };

  // Download file from bucket.
  await bucket.file(filePath).download({destination: tempFilePath});

  // Convert the image to webp using Sharp
  await sharp(tempFilePath).webp().toFile(tempFilePath);

  // Upload the converted image.
  await bucket.upload(
      tempFilePath,
      {
        destination: path.join(path.dirname(filePath), fileName),
        metadata,
      },
  );

  // Clean up the temporary file.
  fs.unlinkSync(tempFilePath);
});