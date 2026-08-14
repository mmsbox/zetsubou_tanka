{
  "ignored_warnings": [
    {
      "warning_type": "File Access",
      "warning_code": 16,
      "fingerprint": "77aa3ce820fdfaadd10b841603edcf58bc935b0dadbacc6bd38431c30c337801",
      "check_name": "SendFile",
      "message": "Model attribute used in file name",
      "file": "app/controllers/posts_controller.rb",
      "line": 64,
      "link": "https://brakemanscanner.org/docs/warning_types/file_access/",
      "code": "send_file(ImageProcessing::MiniMagick.source(MiniMagick::Image.create do\n f.write(\"blank.png\")\n end.tap do\n img.combine_options do\n c.size(\"1200x630\")\nc.canvas(\"#1c1917\")\n end\n end.path).fill(\"#faf6ed\").font(\"Noto-Sans-CJK-JP-Bold\").pointsize(38).gravity(\"center\").draw(\"text 0,-30 '#{(Post.find(params[:id]).tanka or \"\\u30A8\\u30E9\\u30FC\\u5410\\u304D \\u8A60\\u3081\\u306C\\u77ED\\u6B4C\\u306E \\u865A\\u3057\\u3055\\u3088\")}'\").fill(\"#8c1d1d\").pointsize(24).draw(\"text 0,150 '#{\"\\u8A60\\u307F\\u624B\\uFF1A#{(Post.find(params[:id]).author_name or \"\\u540D\\u7121\\u3057\\u6CD5\\u5E2B\")}\"}'\").call.path, :type => \"image/png\", :disposition => \"inline\")",
      "render_path": null,
      "location": {
        "type": "method",
        "class": "PostsController",
        "method": "ogp"
      },
      "user_input": "Post.find(params[:id]).author_name",
      "confidence": "Weak",
      "cwe_id": [
        22
      ],
      "note": ""
    }
  ],
  "brakeman_version": "8.0.5"
}
