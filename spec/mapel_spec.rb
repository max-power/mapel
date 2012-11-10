require "spec_helper"

describe Mapel do

  before {setup_output_dir}
  after {remove_output_dir}

  it "should respond to #info" do
    Mapel.must_respond_to :info
  end

  it "should respond to #render" do
    Mapel.must_respond_to :render
  end
  
  it "should respond to #exif" do
    Mapel.must_respond_to :exif
  end

  it "should support compact rendering syntax" do
    Mapel(logo).must_be_kind_of Mapel::Engine
  end

  describe "Engine" do

    describe "info" do
      it "should return basic image metadata" do
        info = Mapel.info(logo)
        info[:path].must_equal logo
        info[:format].must_equal "JPEG"
        info[:dimensions].must_equal [572, 591]
        info[:depth].must_equal "8-bit"
        ["95.1kb", "97.4KB"].must_include info[:size] # allow KB and KiB
      end

      it "should return an empty hash if metadata can not be extracted" do
        Mapel.info("invalid.jpg").must_equal Hash.new
      end

      it "should be able to read files with spaces in the filename" do
        Mapel.info(multi_word_file)[:path].must_equal multi_word_file
      end
    end

    describe "exif" do
      it "should return EXIF image data" do
        exif = Mapel.exif(rotated_image)
        exif["ExifImageWidth"].must_equal "200"
        exif["ExifImageLength"].must_equal "194"
        exif["XResolution"].must_equal "3000000/10000"
        exif["YResolution"].must_equal "3000000/10000"
        exif["ResolutionUnit"].must_equal "2"
        exif["ColorSpace"].must_equal "65535"
        exif["ExifOffset"].must_equal "164"
        exif["Orientation"].must_equal "6"
        exif["Compression"].must_equal "6"
        exif["JPEGInterchangeFormatLength"].must_equal "7072"
        exif["JPEGInterchangeFormat"].must_equal "302"
        exif["DateTime"].must_equal "2011:06:28 10:40:20"
        exif["Software"].must_equal "Adobe Photoshop CS3 Macintosh"
      end
    end

    describe "list" do
      it "should list ImageMagick commands" do
        Mapel.list.output.must_match /^Version: ImageMagick/
      end
      
      it "should return an array of values if called with an type and true" do
        Mapel.list(:Orientation, true).must_equal ["TopLeft", "TopRight", "BottomRight", "BottomLeft", "LeftTop", "RightTop", "RightBottom", "LeftBottom"]
      end
    end

    describe "render" do
      it "should be able to scale an image" do
        out_file = "#{out_folder}/scaled.jpg"
        cmd = Mapel(logo).scale("50%").to(out_file).run
        cmd.status.must_equal true
        Mapel.info(out_file)[:dimensions].must_equal [286, 296]
      end
  
      it "should be able to crop an image" do
        out_file = "#{out_folder}/cropped.jpg"
        cmd = Mapel(logo).crop("50x50+0+0").to(out_file).run
        cmd.status.must_equal true
        Mapel.info(out_file)[:dimensions].must_equal [50, 50]
      end
  
      it "should be able to resize an image" do
        out_file = "#{out_folder}/cropped.jpg"
        cmd = Mapel(logo).resize("100x").to(out_file).run
        cmd.status.must_equal true
        Mapel.info(out_file)[:dimensions].must_equal [100, 103]
      end
  
      it "should be able to crop-resize an image" do
        out_file = "#{out_folder}/crop_resized.jpg"
        cmd = Mapel(logo).gravity(:west).resize!("50x100").to(out_file).run
        cmd.status.must_equal true
        Mapel.info(out_file)[:dimensions].must_equal [50, 100]
      end
  
      it "should allow arbitrary addition of commands to the queue" do
        cmd = Mapel(logo).gravity(:west)
        cmd.resize(50, 50)
        cmd.to_preview.must_equal %(convert "#{logo}" -gravity west -resize "50x50")
      end
  
      it "should allow stripping additional image metadata" do
        out_file = "#{out_folder}/stripped.jpg"
        cmd = Mapel(rotated_image).strip.to(out_file).run
        cmd.status.must_equal true
        Mapel.exif(out_file).must_equal Hash.new
      end
  
      it "should be able to handle input filenames containing spaces" do
        out_file = "#{out_folder}/resized.jpg"
        cmd = Mapel(multi_word_file).resize("100x").to(out_file).run
        cmd.status.must_equal true
        Mapel.info(out_file)[:dimensions].must_equal [100, 103]
      end
  
      it "should be able to handle output filenames containing spaces" do
        out_file = "#{out_folder}/multi-word file.jpg"
        cmd = Mapel(logo).resize("100x").to(out_file).run
        cmd.status.must_equal true
        Mapel.info(out_file)[:dimensions].must_equal [100, 103]
      end
  
      it "should allow automatic rotation of images" do
        out_file = "#{out_folder}/rotated.jpg"
        cmd = Mapel(rotated_image).orient.to(out_file).run
        cmd.status.must_equal true
        Mapel.exif(out_file)["Orientation"].must_equal "1"
        Mapel.info(out_file)[:dimensions].must_equal [194, 200]
      end
    end
  end
end