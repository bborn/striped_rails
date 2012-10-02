module StripedRails::BaseHelper

  def conditional_html(&blok)
    html_tag = <<-EOS
      <!-- paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/ -->
      <!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
      <!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="en"> <![endif]-->
      <!--[if IE 8]>    <html class="no-js lt-ie9" lang="en"> <![endif]-->
      <!-- Consider adding a manifest.appcache: h5bp.com/d/Offline -->
      <!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
    EOS
    html_tag + capture_haml(&blok).strip + "</html>"
  end
  
  def title(page_title)
    content_for(:title, page_title.to_s.html_safe)
  end
  
end
