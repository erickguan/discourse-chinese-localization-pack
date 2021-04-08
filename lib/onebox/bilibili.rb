module Onebox
  module Engine
    class BilibiliOnebox
      include Engine
      include HTML

      matches_regexp(/^https?:\/\/(?:www\.)?bilibili\.com\/video\/([A-z0-9]+)\/?$/)

      # Try to get the video ID. Works for URLs of the form:
      # * http://www.bilibili.com/video/av4235068/
      def video_id
        
        match = uri.path.match(/\/video\/(.*)(\.html)?.*/)

        return match[1] if match && match[1]

        nil
      rescue
        return nil
      end

      def to_html
        "<iframe src='https://player.bilibili.com/player.html?bvid=#{video_id}&high_quality=1' scrolling='no' border='0' frameborder='no' framespacing='0' width='100%' height='430' allowfullscreen='true'></iframe>"
      end

      def placeholder_html
        to_html
      end
    end
  end
end
