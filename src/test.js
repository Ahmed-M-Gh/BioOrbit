require("dotenv").config();

const cloudinary = require("./config/cloudinary");

const testConnection = async () => {
  try {
    console.log("Checking Cloudinary configuration...");

    console.log({
      cloudName: !!process.env.CLOUDINARY_CLOUD_NAME,
      apiKey: !!process.env.CLOUDINARY_API_KEY,
      apiSecret: !!process.env.CLOUDINARY_API_SECRET,
    });

    const result = await cloudinary.api.ping();

    console.log("Cloudinary Connected Successfully 🚀");
    console.log(result);
  } catch (error) {
    console.error("Cloudinary Error Details:");
    console.error(error);

    console.error("Error Message:", error?.message);
    console.error("HTTP Code:", error?.http_code);
  }
};

testConnection();
