const HealthRecord = require("../models/HealthRecord");
const imageService = require("../services/imageService");

const uploadAstroImage = async (req, res) => {
  let uploadedImage;

  try {
    // Check if image exists
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "Please upload an image",
      });
    }

    // Find record owned by the logged-in Astro
    const record = await HealthRecord.findOne({
      _id: req.params.recordId,
      astronaut: req.user._id,
    });

    if (!record) {
      return res.status(404).json({
        success: false,
        message: "Health record not found",
      });
    }

    // Upload image to Cloudinary
    uploadedImage = await imageService.uploadImage(req.file.buffer);

    const oldPublicId = record.image?.publicId;

    // Save image data in MongoDB
    record.image = {
      imageUrl: uploadedImage.imageUrl,
      publicId: uploadedImage.publicId,
    };

    await record.save();

    // Delete old image after successful update
    if (oldPublicId) {
      try {
        await imageService.deleteImage(oldPublicId);
      } catch (error) {
        console.error("Old image deletion failed:", error.message);
      }
    }

    return res.status(200).json({
      success: true,
      message: "Image uploaded successfully",
      data: {
        recordId: record._id,
        image: record.image,
      },
    });
  } catch (error) {
    // Cleanup newly uploaded image if database update fails
    if (uploadedImage?.publicId) {
      try {
        await imageService.deleteImage(uploadedImage.publicId);
      } catch (cleanupError) {
        console.error("Image cleanup failed:", cleanupError.message);
      }
    }

    console.error("Upload Astro Image Error:", error);

    return res.status(500).json({
      success: false,
      message: "Image upload failed",
    });
  }
};

module.exports = {
  uploadAstroImage,
};
