const functions = require("firebase-functions");
const admin = require("firebase-admin");
const sharp = require("sharp");
const {Storage} = require("@google-cloud/storage");

admin.initializeApp();
const storage = new Storage();

exports.generateThumbnail = functions.storage.object().onFinalize(async (object) => {
  const fileBucket = object.bucket;
  const filePath = object.name;
  const contentType = object.contentType;

  // Skip non-images
  if (!contentType.startsWith("image/")) return null;

  // Skip if already thumbnail
  if (filePath.includes("thumbnails/")) return null;

  const bucket = storage.bucket(fileBucket);
  const fileName = filePath.split("/").pop();
  const tempFilePath = `/tmp/${fileName}`;
  const thumbFilePath = `thumbnails/${fileName}`;

  await bucket.file(filePath).download({destination: tempFilePath});

  // Create thumbnail
  await sharp(tempFilePath)
    .resize({width: 400})
    .jpeg({quality: 70})
    .toFile(tempFilePath + "_thumb.jpg");

  // Upload thumbnail
  await bucket.upload(tempFilePath + "_thumb.jpg", {
    destination: thumbFilePath,
    contentType: "image/jpeg",
  });

  return bucket.file(thumbFilePath).makePublic();
});
