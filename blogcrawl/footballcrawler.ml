(* Compile: ocamlfind ocamlopt -linkpkg -package netclient -package extlib -package sqlite3 -package unix footballcrawler.ml -o footballcrawler *)

open Neturl
open Http_client
open Netchannels
open Nethtml
open Netencoding
open Array
open ExtList
open ExtString.String
open Printf
open OptParse


let default_db_name = "footballblogs.sql"
let default_file_name = "latestentries.txt"
let default_nb_links = 15
let page_retries = ref 3
let retry_delay = ref 5

type feed = { feed_club: string; feed_name: string; feed_url: string; feed_rss: string }
let feeds = [
  {feed_club="Arsenal"; feed_name="7 AM Kickoff"; feed_url="http://7amkickoff.wordpress.com/"; feed_rss="http://7amkickoff.wordpress.com/feed/"};
  {feed_club="Arsenal"; feed_name="A Cultured Left Foot"; feed_url="http://aculturedleftfoot.wordpress.com/"; feed_rss="http://feeds.feedburner.com/ACulturedLeftFoot"};
  {feed_club="Arsenal"; feed_name="Another Arsenal Blog"; feed_url="http://anotherarsenalblog.blogspot.com/"; feed_rss="http://anotherarsenalblog.blogspot.com/feeds/posts/default?alt=rss"};
(*  {feed_club="Arsenal"; feed_name="Arse Online"; feed_url="http://arsenal.rivals.net/teams/pgclubhome.aspx?clubid=2"; feed_rss="http://www.rivals.net/Services/Rss/pgClubNews.aspx?id=2"}; *)
  {feed_club="Arsenal"; feed_name="Arseblog"; feed_url="http://www.oleole.com/blogs/arseblog/"; feed_rss="http://feedproxy.google.com/arseblog?format=xml"};
  {feed_club="Arsenal"; feed_name="Arsenal 4 Life"; feed_url="http://www.afc4life.co.uk/"; feed_rss="http://feeds.feedburner.com/Arsenal4Life"};
  {feed_club="Arsenal"; feed_name="Arsenal Addict"; feed_url="http://www.arsenaladdict.com/"; feed_rss="http://www.arsenaladdict.com/home/rss.xml"};
  {feed_club="Arsenal"; feed_name="Arsenal Analysis"; feed_url="http://arsenalanalysis.blogspot.com/"; feed_rss="http://arsenalanalysis.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Arsenal"; feed_name="Arsenal Column"; feed_url="http://arsenalcolumn.wordpress.com/"; feed_rss="http://feeds.feedburner.com/ArsenalColumn?format=xml"};
  {feed_club="Arsenal"; feed_name="Arsenal FC Blog"; feed_url="http://arsenalfcblog.com/"; feed_rss="http://feeds.feedburner.com/arsenalfcblog?format=xml"};
  {feed_club="Arsenal"; feed_name="Arsenal Insider"; feed_url="http://www.arsenalinsider.com/"; feed_rss="http://www.arsenalinsider.com/?feed=rss2"};
  {feed_club="Arsenal"; feed_name="Arsenal Land"; feed_url="http://www.arsenal-land.co.uk/"; feed_rss="http://www.arsenal-land.co.uk/rss.php"};
(*   {feed_club="Arsenal"; feed_name="Arsenal Mania"; feed_url="http://arsenal-mania.com/"; feed_rss="http://static.arsenal-mania.com/static/mania-articles.xml"}; *)
  {feed_club="Arsenal"; feed_name="Arsenal Online"; feed_url="http://www.arsenalonline.com/"; feed_rss="http://feeds.feedburner.com/ArsenalOnline?format=xml"};
  {feed_club="Arsenal"; feed_name="Arsenal Opinion"; feed_url="http://arsenal-opinion.com/"; feed_rss="http://arsenal-opinion.com/feed/"};
  {feed_club="Arsenal"; feed_name="Arsenal Spot"; feed_url="http://arsenalspot.wordpress.com/"; feed_rss="http://feeds.feedburner.com/arsenalspot?format=xml"};
  {feed_club="Arsenal"; feed_name="Arsenal Truth"; feed_url="http://www.oleole.com/blogs/arsenal-truth/"; feed_rss="http://www.oleole.com/blogs/arsenal-truth/rss"};
  {feed_club="Arsenal"; feed_name="Arsenal Youth"; feed_url="http://arsenalyouth.wordpress.com/"; feed_rss="http://arsenalyouth.wordpress.com/feed/"};
  {feed_club="Arsenal"; feed_name="Arsenalist"; feed_url="http://arsenalist.com/"; feed_rss="http://feedproxy.google.com/Gunners?format=xml"};
  {feed_club="Arsenal"; feed_name="Arsespeak"; feed_url="http://arsespeak.wordpress.com/"; feed_rss="http://arsespeak.wordpress.com/feed/"};
  {feed_club="Arsenal"; feed_name="Carlos Vela News"; feed_url="http://carlosvelanews.wordpress.com/"; feed_rss="http://carlosvelanews.wordpress.com/feed/"};
  {feed_club="Arsenal"; feed_name="Clock Enders"; feed_url="http://clockenders.com/afc/"; feed_rss="http://clockenders.com/afc/?feed=rss2"};
  {feed_club="Arsenal"; feed_name="East Lower"; feed_url="http://eastlower.co.uk/"; feed_rss="http://eastlower.co.uk/?feed=rss2"};
  {feed_club="Arsenal"; feed_name="Fab 4 Arsenal"; feed_url="http://fab4arsenal.blogspot.com/"; feed_rss="http://fab4arsenal.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Arsenal"; feed_name="GoodPlaya"; feed_url="http://www.arsepod.co.uk/"; feed_rss="http://www.arsepod.co.uk/2008/feed/"};
  {feed_club="Arsenal"; feed_name="Gooner Get Ya"; feed_url="http://goonergetya.blogspot.com/"; feed_rss="http://goonergetya.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Arsenal"; feed_name="Gooner Talk"; feed_url="http://goonertalk.com/"; feed_rss="http://feedproxy.google.com/goonertalk2?format=xml"};
  {feed_club="Arsenal"; feed_name="GoonerBoy"; feed_url="http://goonerboy.blogspot.com/"; feed_rss="http://feeds.feedburner.com/Goonerboy"};
  {feed_club="Arsenal"; feed_name="Goonerholic"; feed_url="http://goonerholic.com/"; feed_rss="http://goonerholic.com/?feed=rss2"};
  {feed_club="Arsenal"; feed_name="Gooner's Diary"; feed_url="http://goonersdiary.blogspot.com/"; feed_rss="http://goonersdiary.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Arsenal"; feed_name="Gooners World"; feed_url="http://goonersworld.wordpress.com/"; feed_rss="http://goonersworld.wordpress.com/feed/"};
  {feed_club="Arsenal"; feed_name="Hidup Marti Arsenal"; feed_url="http://hidupmatiarsenal.blogspot.com/"; feed_rss="http://hidupmatiarsenal.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Arsenal"; feed_name="Le Grove"; feed_url="http://le-grove.co.uk/"; feed_rss="http://feeds.feedburner.com/LeGrove?format=xml"};
(*   {feed_club="Arsenal"; feed_name="LG's Arsenal Blog"; feed_url="http://blogs.goonerville.com/blog/LGS_blog.php"; feed_rss="http://blogs.goonerville.com/blog/rss/LGS_blog_rss2.xml"}; *)
  {feed_club="Arsenal"; feed_name="One Nil to the Arsenal"; feed_url="http://young-arsenal.blogspot.com/"; feed_rss="http://young-arsenal.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Arsenal"; feed_name="The Arsenal Way"; feed_url="http://thearsenalway.wordpress.com/"; feed_rss="http://feeds.feedburner.com/wordpress/thearsenalway?format=xml"};
  {feed_club="Arsenal"; feed_name="The ArseNole"; feed_url="http://arsenole.com/"; feed_rss="http://feeds.feedburner.com/TheArsenole?format=xml"};
  {feed_club="Arsenal"; feed_name="The Cannon"; feed_url="http://the-cannon.com/"; feed_rss="http://the-cannon.com/feed/"};
  {feed_club="Arsenal"; feed_name="The Goon"; feed_url="http://thegoonblog.wordpress.com/"; feed_rss="http://thegoonblog.wordpress.com/feed/"};
  {feed_club="Arsenal"; feed_name="The Gooner Forum"; feed_url="http://thegoonerforum.wordpress.com/"; feed_rss="http://thegoonerforum.wordpress.com/feed/"};
  {feed_club="Arsenal"; feed_name="The Gunning Hawk"; feed_url="http://www.thegunninghawk.com/"; feed_rss="http://feedproxy.google.com/arsenalblog?format=xml"};
  {feed_club="Arsenal"; feed_name="The Offside"; feed_url="http://arsenal.theoffside.com/"; feed_rss="http://arsenal.theoffside.com/feed/"};
  {feed_club="Arsenal"; feed_name="The Online Gooner"; feed_url="http://onlinegooner.com/"; feed_rss="http://onlinegooner.com/rss/index.php"};
  {feed_club="Arsenal"; feed_name="The World of Arsenal"; feed_url="http://worldofarsenal.co.uk/"; feed_rss="http://worldofarsenal.co.uk/feed/"};
  {feed_club="Arsenal"; feed_name="Untold Arsenal"; feed_url="http://www.blog.emiratesstadium.info/"; feed_rss="http://blog.emiratesstadium.info/?feed=rss2"};
  {feed_club="Arsenal"; feed_name="Wengerball"; feed_url="http://www.wengerball.com/"; feed_rss="http://feeds.feedburner.com/wengerball"};
  {feed_club="Arsenal"; feed_name="Wicked Defection"; feed_url="http://www.wickeddeflection.com/"; feed_rss="http://www.wickeddeflection.com/feeds/posts/default"};
  {feed_club="Arsenal"; feed_name="Wrighty 7"; feed_url="http://www.wrighty7.blogspot.com/"; feed_rss="http://www.wrighty7.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Arsenal"; feed_name="Young Guns"; feed_url="http://youngguns.wordpress.com/"; feed_rss="http://youngguns.wordpress.com/feed/"};
  {feed_club="Liverpool"; feed_name="A Liverpool Thing"; feed_url="http://www.aliverpoolthing.blogspot.com/"; feed_rss="http://feeds.feedburner.com/ALiverpoolThing?format=xml"};
  {feed_club="Liverpool"; feed_name="Anfield Is Calling"; feed_url="http://anfieldiscalling.blogspot.com/"; feed_rss="http://feeds.feedburner.com/AnfieldIsCalling?format=xml"};
  {feed_club="Liverpool"; feed_name="Anfield Kopites"; feed_url="http://anfield-kopites.blogspot.com/"; feed_rss="http://feeds.feedburner.com/LiverpoolandMe"};
  {feed_club="Liverpool"; feed_name="Anfield Online"; feed_url="http://www.anfield-online.co.uk/"; feed_rss="http://feeds.feedburner.com/lfcreds"};
  {feed_club="Liverpool"; feed_name="Anfield Red"; feed_url="http://www.anfieldred.co.uk/"; feed_rss="http://feeds.feedburner.com/anfieldred"};
  {feed_club="Liverpool"; feed_name="Anfield Reds"; feed_url="http://anfieldreds.blogspot.com/"; feed_rss="http://feeds.feedburner.com/anfieldredsblogspot?format=xml"};
  {feed_club="Liverpool"; feed_name="Anfield Road"; feed_url="http://www.anfieldroad.com/"; feed_rss="http://www.anfieldroad.com/feed/"};
  {feed_club="Liverpool"; feed_name="Anfield Talk"; feed_url="http://anfieldtalk.blogspot.com/"; feed_rss="http://anfieldtalk.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Liverpool"; feed_name="Have You Ever Been To Liverpool"; feed_url="http://redfloyd.wordpress.com/"; feed_rss="http://redfloyd.wordpress.com/feed/"};
  {feed_club="Liverpool"; feed_name="Kop talk Insider"; feed_url="http://koptalkinsider.wordpress.com/"; feed_rss="http://koptalkinsider.wordpress.com/feed/"};
  {feed_club="Liverpool"; feed_name="KopBlog"; feed_url="http://www.thisisanfield.com/kopblog/"; feed_rss="http://www.thisisanfield.com/kopblog/feed"};
  {feed_club="Liverpool"; feed_name="Liverpool Banter"; feed_url="http://www.liverpoolbanter.co.uk/"; feed_rss="http://feeds.feedburner.com/LiverpoolBanter?format=xml"};
  {feed_club="Liverpool"; feed_name="Liverpool Fanatics"; feed_url="http://www.lfcfanatics.blogspot.com/"; feed_rss="http://lfcfanatics.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Liverpool"; feed_name="Liverpool FC Weblog"; feed_url="http://manar8gerrard.wordpress.com/"; feed_rss="http://manar8gerrard.wordpress.com/feed/"};
  {feed_club="Liverpool"; feed_name="Luke Traynor"; feed_url="http://luketraynor.merseyblogs.co.uk/"; feed_rss="http://feeds.feedburner.com/LiverpoolEcho-AnotherRedLetterDay?format=xml"};
  {feed_club="Liverpool"; feed_name="My Anfield"; feed_url="http://www.myanfield.net/"; feed_rss="http://feeds.feedburner.com/MyAnfield?format=xml"};
(*   {feed_club="Liverpool"; feed_name="My Friggin'Mind"; feed_url="http://looprevil4ever.blogspot.com/"; feed_rss="http://looprevil4ever.blogspot.com/feeds/posts/default?alt=rss"}; *)
  {feed_club="Liverpool"; feed_name="On The Kop"; feed_url="http://onthekop.com/main/"; feed_rss="http://www.onthekop.com/main/index.php?option=com_rss&feed=ATOM0.3&no_html=1"};
  {feed_club="Liverpool"; feed_name="One Fan's View"; feed_url="http://liverpoolfc-onefansview.blogspot.com/"; feed_rss="http://liverpoolfc-onefansview.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Liverpool"; feed_name="Paul Tomkin's"; feed_url="http://tomkins-blogs.typepad.com/paul_tomkins_blog/"; feed_rss="http://tomkins-blogs.typepad.com/paul_tomkins_blog/atom.xml"};
  {feed_club="Liverpool"; feed_name="Red And White Kop"; feed_url="http://blog.redandwhitekop.com/"; feed_rss="http://blog.redandwhitekop.com/feed/"};
  {feed_club="Liverpool"; feed_name="Red In Dublin"; feed_url="http://irishkopite.blogspot.com/"; feed_rss="http://irishkopite.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Liverpool"; feed_name="Red Walk"; feed_url="http://redwalk.freeblogit.com/"; feed_rss="http://redwalk.freeblogit.com/feed/"};
  {feed_club="Liverpool"; feed_name="Red's Fury"; feed_url="http://redsfury.blogspot.com/"; feed_rss="http://feeds.feedburner.com/RedsFury2?format=xml"};
(*   {feed_club="Liverpool"; feed_name="Shanky Gates"; feed_url="http://liverpool.rivals.net/teams/pgclubhome.aspx?clubid=46"; feed_rss="http://www.rivals.net/Services/Rss/pgClubNews.aspx?id=46"}; *)
  {feed_club="Liverpool"; feed_name="The Liverpool Way"; feed_url="http://www.liverpoolway.co.uk/blog/"; feed_rss="http://www.liverpoolway.co.uk/blog/?feed=rss2"};
  {feed_club="Liverpool"; feed_name="The Offside"; feed_url="http://liverpool.theoffside.com/"; feed_rss="http://liverpool.theoffside.com/feed/"};
  {feed_club="Liverpool"; feed_name="The Red Cauldron"; feed_url="http://theredcauldron.blogspot.com/"; feed_rss="http://feeds.feedburner.com/Drogballs"};
  {feed_club="Liverpool"; feed_name="Our Kop"; feed_url="http://www.ourkop.com/"; feed_rss="http://www.ourkop.com/feed/"};
  {feed_club="Liverpool"; feed_name="Oh You Beauty"; feed_url="http://ohyoubeauty.blogspot.com/"; feed_rss="http://ohyoubeauty.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Liverpool"; feed_name="Liverpool Captain"; feed_url="http://liverpoolcaptain.blogspot.com/"; feed_rss="http://feeds.feedburner.com/Anfield?format=xml"};
  {feed_club="Liverpool"; feed_name="Coops Blog"; feed_url="http://coop75.wordpress.com/"; feed_rss="http://feeds.feedburner.com/CoopsLfcViewsAndNews?format=xml"};
  {feed_club="Liverpool"; feed_name="Liverweb Blog"; feed_url="http://liverweb.blogspot.com/"; feed_rss="http://liverweb.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Liverpool"; feed_name="Well Red"; feed_url="http://robbohuyton.blogspot.com/"; feed_rss="http://robbohuyton.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Manchester United"; feed_name="A Kick In The Grass"; feed_url="http://a-kick-in-the-grass.blogspot.com/"; feed_rss="http://a-kick-in-the-grass.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Manchester United"; feed_name="Absolutely United"; feed_url="http://www.absolutelyunited.com/"; feed_rss="http://absolutelyunited.com/redcan/feed/"};
  {feed_club="Manchester United"; feed_name="Between The Lines"; feed_url="http://hakanrylander.wordpress.com/"; feed_rss="http://hakanrylander.wordpress.com/feed/"};
  {feed_club="Manchester United"; feed_name="Blog United"; feed_url="http://www.blogunited.co.uk/"; feed_rss="http://www.blogunited.co.uk/feed"};
  {feed_club="Manchester United"; feed_name="Carly's Manchester United Blog"; feed_url="http://carlyluvsunited.blogspot.com/"; feed_rss="http://feeds.feedburner.com/CarlyWillFollowFollowFollowUnited"};
  {feed_club="Manchester United"; feed_name="Everything That's United"; feed_url="http://soldtounited.wordpress.com/"; feed_rss="http://soldtounited.wordpress.com/feed/"};
  {feed_club="Manchester United"; feed_name="Forever Man Utd"; feed_url="http://www.forevermanutd.com/"; feed_rss="http://forevermanutd.com/component/option,com_rss/feed,RSS2.0/no_html,1/"};
  {feed_club="Manchester United"; feed_name="Johnny Evan's News"; feed_url="http://jonnyevansnews.blogspot.com/"; feed_rss="http://jonnyevansnews.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Manchester United"; feed_name="Man United Devils"; feed_url="http://manuniteddevils.blogspot.com/"; feed_rss="http://feeds.feedburner.com/manuniteddevils?format=xml"};
  {feed_club="Manchester United"; feed_name="Man Utd 24"; feed_url="http://manutd24.wordpress.com/"; feed_rss="http://feeds.feedburner.com/manutd-24?format=xml"};
  {feed_club="Manchester United"; feed_name="Man Utd Blog"; feed_url="http://www.manutdblog.com/"; feed_rss="http://feeds.feedburner.com/manutd-blog"};
  {feed_club="Manchester United"; feed_name="Man Utd Daily News"; feed_url="http://www.manutddailynews.com/"; feed_rss="http://feedproxy.google.com/manutddailynews/btiR?format=xml"};
  {feed_club="Manchester United"; feed_name="Man Utd Musings"; feed_url="http://www.newmanutd.com/"; feed_rss="http://www.newmanutd.com/feed/"};
  {feed_club="Manchester United"; feed_name="Manchester United Blog"; feed_url="http://manutd.blogsfc.com/"; feed_rss="http://manutd.blogsfc.com/feed/"};
  {feed_club="Manchester United"; feed_name="Manchester United Blog"; feed_url="http://www.manchesterunited-blog.com/"; feed_rss="http://www.manchesterunited-blog.com/feed/"};
  {feed_club="Manchester United"; feed_name="Manchester United Dugout"; feed_url="http://manchesteruniteddugout.blogspot.com/"; feed_rss="http://manchesteruniteddugout.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Manchester United"; feed_name="Manchester United Fan Site"; feed_url="http://news-manutd.blogspot.com/"; feed_rss="http://feeds.feedburner.com/newsmanutd?format=xml"};
  {feed_club="Manchester United"; feed_name="Manchester United FC Blog"; feed_url="http://manchesterunitedsblog.blogspot.com/"; feed_rss="http://feedproxy.google.com/ManchesterUnitedsBlog?format=xml"};
(*   {feed_club="Manchester United"; feed_name="Manchester United Rivals.net"; feed_url="http://manchesterunited.rivals.net/teams/pgclubhome.aspx?clubid=50"; feed_rss="http://www.rivals.net/Services/Rss/pgClubNews.aspx?id=50"}; *)
  {feed_club="Manchester United"; feed_name="MUFC The Religion"; feed_url="http://redtilldeath.blogspot.com/"; feed_rss="http://redtilldeath.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Manchester United"; feed_name="My United, My Life"; feed_url="http://spectregoesred.blogspot.com/"; feed_rss="http://feeds.feedburner.com/MyUnitedMyLife"};
  {feed_club="Manchester United"; feed_name="Penguin United"; feed_url="http://penguinunited.blogspot.com/"; feed_rss="http://feeds.feedburner.com/PenguinUnited?format=xml"};
  {feed_club="Manchester United"; feed_name="Red Blood Blog"; feed_url="http://red-blood-blog.blogspot.com/"; feed_rss="http://feedproxy.google.com/blogspot/GDRB?format=xml"};
  {feed_club="Manchester United"; feed_name="Red Rants"; feed_url="http://redrants.com/"; feed_rss="http://feeds.feedburner.com/redrants?format=xml"};
  {feed_club="Manchester United"; feed_name="Red United"; feed_url="http://red-united.blogspot.com/"; feed_rss="http://red-united.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Manchester United"; feed_name="The Offside"; feed_url="http://manu.theoffside.com/"; feed_rss="http://manu.theoffside.com/feed/"};
  {feed_club="Manchester United"; feed_name="The Republik of Mancunia"; feed_url="http://therepublikofmancunia.com/"; feed_rss="http://feeds.feedburner.com/therepublikofmancunia?format=xml"};
  {feed_club="Manchester United"; feed_name="The Stretty Rant"; feed_url="http://www.stretford-end.com/blog/"; feed_rss="http://www.stretford-end.com/blog/?feed=rss2"};
  {feed_club="Manchester United"; feed_name="Truly Reds"; feed_url="http://www.trulyreds.com/"; feed_rss="http://www.trulyreds.com/feed/"};
  {feed_club="Manchester United"; feed_name="United Blog"; feed_url="http://unitedblog.typepad.com/"; feed_rss="http://unitedblog.typepad.com/my_weblog/atom.xml"};
  {feed_club="Manchester United"; feed_name="United On Fire"; feed_url="http://www.unitedonfire.co.uk/"; feed_rss="http://feeds.feedburner.com/UnitedOnFire?format=xml"};
  {feed_club="Manchester United"; feed_name="United Till I Die, No Lie"; feed_url="http://utdtillidie.blogspot.com/"; feed_rss="http://utdtillidie.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Manchester United"; feed_name="United Youth"; feed_url="http://manunitedyouth.wordpress.com/"; feed_rss="http://manunitedyouth.wordpress.com/feed/"};
  {feed_club="Newcastle United"; feed_name="Black & White @ Read all over"; feed_url="http://www.blackandwhiteandreadallover.blogspot.com/"; feed_rss="http://www.blackandwhiteandreadallover.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Newcastle United"; feed_name="Blog On The Tyne"; feed_url="http://www.blogonthetyne.co.uk/"; feed_rss="http://feeds.feedburner.com/ChronicleLive-BlogOnTheTyne?format=xml"};
  {feed_club="Newcastle United"; feed_name="Eat Sleep Drink Toon"; feed_url="http://eatsleepdrinktoon.blogspot.com/"; feed_rss="http://eatsleepdrinktoon.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Newcastle United"; feed_name="Howay The Toon"; feed_url="http://howaythetoon.co.uk/"; feed_rss="http://feeds.feedburner.com/howaythetoon?format=xml"};
(*   {feed_club="Newcastle United"; feed_name="Izzy Rocks"; feed_url="http://izzy69nufc.blogspot.com/"; feed_rss="http://izzy69nufc.blogspot.com/feeds/posts/default?alt=rss"}; *)
  {feed_club="Newcastle United"; feed_name="Ken's Newcastle  United Blog"; feed_url="http://nufc-toon-blog.spaces.live.com/"; feed_rss="http://nufc-toon-blog.spaces.live.com/feed.rss"};
  {feed_club="Newcastle United"; feed_name="Magpies Zone"; feed_url="http://www.magpieszone.com/"; feed_rss="http://feeds.feedburner.com/magpieszone?format=xml"};
  {feed_club="Newcastle United"; feed_name="Newcastle Latest Results"; feed_url="http://newcastleslatest.blogspot.com/"; feed_rss="http://newcastleslatest.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Newcastle United"; feed_name="Newcastle Online"; feed_url="http://www.newcastle-online.org/"; feed_rss="http://www.newcastle-online.org/feed/"};
  {feed_club="Newcastle United"; feed_name="Newcastle United Blogger"; feed_url="http://www.newcastleunitedblogger.com/"; feed_rss="http://feeds.feedburner.com/NewcastleUnitedBlogger?format=xml"};
  {feed_club="Newcastle United"; feed_name="Newcastle United Mad"; feed_url="http://www.newcastleunited-mad.co.uk/"; feed_rss="http://www.newcastleunited-mad.co.uk/rssfeeds/rssfull.asp"};
  {feed_club="Newcastle United"; feed_name="Newcastle United News"; feed_url="http://www.newcastledailynews.com/"; feed_rss="http://feedproxy.google.com/NewcastleUnitedNews"};
(*   {feed_club="Newcastle United"; feed_name="Talk Of The Tyne"; feed_url="http://newcastleunited.rivals.net/teams/pgclubhome.aspx?clubid=55"; feed_rss="http://www.rivals.net/Services/Rss/pgClubNews.aspx?id=55"}; *)
  {feed_club="Newcastle United"; feed_name="The Newcastle United Blog"; feed_url="http://www.nufcblog.com/"; feed_rss="http://feeds.feedburner.com/nufcblog?format=xml"};
  {feed_club="Newcastle United"; feed_name="The Offside"; feed_url="http://newcastle.theoffside.com/"; feed_rss="http://newcastle.theoffside.com/feed/"};
  {feed_club="Tottenham Hotspur"; feed_name="All Action No Plot"; feed_url="http://www.allactionnoplot.com/"; feed_rss="http://www.allactionnoplot.com/?feed=rss2"};
  {feed_club="Tottenham Hotspur"; feed_name="Beef Bagel"; feed_url="http://beefbagel.com/"; feed_rss="http://beefbagel.com/feed/"};
  {feed_club="Tottenham Hotspur"; feed_name="Chivers Down My Backbone"; feed_url="http://chiversdownmybackbone.blogspot.com/"; feed_rss="http://chiversdownmybackbone.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Tottenham Hotspur"; feed_name="Chivers Me Timbers"; feed_url="http://chiversmetimbers.blogspot.com/"; feed_rss="http://chiversmetimbers.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Tottenham Hotspur"; feed_name="Dear Mr Levy"; feed_url="http://www.dearmrlevy.com/"; feed_rss="http://www.dearmrlevy.com/dml/rss.xml"};
  {feed_club="Tottenham Hotspur"; feed_name="E-Spurs Blog"; feed_url="http://www.espurs.blogspot.com/"; feed_rss="http://espurs.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Tottenham Hotspur"; feed_name="Harry Hotspur"; feed_url="http://www.oleole.com/blogs/harryhotspur"; feed_rss="http://www.oleole.com/blogs/harryhotspur/rss"};
  {feed_club="Tottenham Hotspur"; feed_name="JimmyG2"; feed_url="http://jimmyg2.blogspot.com/"; feed_rss="http://jimmyg2.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Tottenham Hotspur"; feed_name="JSG Spurs"; feed_url="http://www.jsgspurs.com/"; feed_rss="http://feeds.feedburner.com/JSGSpurs?format=xml"};
  {feed_club="Tottenham Hotspur"; feed_name="N7teen"; feed_url="http://www.n7teen.com/"; feed_rss="http://feeds.feedburner.com/N7teen"};
  {feed_club="Tottenham Hotspur"; feed_name="Spurs For Life"; feed_url="http://www.spursforlife.com/"; feed_rss="http://feeds.feedburner.com/SpursForLife?format=xml"};
  {feed_club="Tottenham Hotspur"; feed_name="The Offside"; feed_url="http://spurs.theoffside.com/"; feed_rss="http://spurs.theoffside.com/feed/"};
  {feed_club="Tottenham Hotspur"; feed_name="The Shelf"; feed_url="http://theshelf.blogspot.com/"; feed_rss="http://feeds.feedburner.com/blogspot/xLXu?format=xml"};
(*   {feed_club="Tottenham Hotspur"; feed_name="The Spurs Web"; feed_url="http://tottenhamhotspur.rivals.net/teams/pgclubhome.aspx?clubid=81"; feed_rss="http://www.rivals.net/Services/Rss/pgClubNews.aspx?id=81"}; *)
  {feed_club="Tottenham Hotspur"; feed_name="THFC Latest 2"; feed_url="http://www.thfclatest2-matchreports.com/blog/"; feed_rss="http://feeds.feedburner.com/Thfclatest2-CocksToTheWest"};
  {feed_club="Tottenham Hotspur"; feed_name="Tottenham Hot Spurs Blog"; feed_url="http://spurs.blogsfc.com/"; feed_rss="http://spurs.blogsfc.com/feed/"};
  {feed_club="Tottenham Hotspur"; feed_name="Tottenham Hotspur Blog News"; feed_url="http://tottenhamhotspur.blogspot.com/"; feed_rss="http://tottenhamhotspur.blogspot.com/feeds/posts/default?alt=rss"};
  {feed_club="Tottenham Hotspur"; feed_name="Tottenham Hotspur Blogs"; feed_url="http://www.tottenhamhotspurs.tv/forum/blog.php"; feed_rss="http://www.tottenhamhotspurs.tv/forum/blogs/feed.rss"};
  {feed_club="Tottenham Hotspur"; feed_name="White Hart Pain"; feed_url="http://www.whitehartpain.com/"; feed_rss="http://whitehartpain.com/feed"}
  ]

(* UTILITY FUNCTIONS *)
let ( |> ) x f = f x


let error_exit message =
  printf "Error: %s\n%!" message;
  exit 0

let trim text =
  let rec pass char_list keep_space keep_cr acc =
    match char_list with
      [] -> acc
    | h::t when h = '\b' -> pass t false keep_cr acc
    | h::t when h = ' ' || h = '\t' -> pass t false keep_cr (if keep_space then (h::acc) else acc)
    | h::t when h = '\n' || h = '\r' -> pass t false false (if keep_cr then ('\n'::acc) else acc)
    | h::t -> pass t true true (h::acc)
  in
  implode (pass (pass (explode text) false false []) false false [])

let dequote text = ExtString.String.replace_chars (fun c -> match c with '\'' -> "\'\'" | _ -> (of_char c)) text

let is_invalid_url url_string =
  try (ignore (parse_url url_string); false) with Malformed_URL -> (printf "Malformed URL: <%s>\n%!" url_string; true)


(* DATABASE FUNCTIONS *)
let rec close_db db_handle db_name =
  printf "Closing database %s\n%!" db_name;
  if (try Sqlite3.db_close db_handle with Sqlite3.Error (message) -> error_exit ("Invalid handle when closing database file <"^db_name^"> : "^message))
  then () (* closing went well *)
  else begin (* database was busy: wait 30 secs and retry *)
    Unix.sleep 30;
    close_db db_handle db_name
  end

let exec_db_get_id create exact db_handle db_name table column value =
(*   printf "getid: %B %s.%s = %s\n" create table column value; *)
  let row_id = ref (-1)
  and db_value = lowercase (dequote value) in
  let callback (r : Sqlite3.row) (h: Sqlite3.headers) =
    row_id := if Array.length r > 0 then int_of_string (match r.(0) with Some s -> s | None -> "-1") else -1
  and condition = if exact then " = '" ^ db_value ^ "'" else " = substr('" ^ db_value ^ "', 1, length(" ^ column ^ "))" in
  let select_query = "SELECT id FROM " ^ table ^ " WHERE " ^ column ^ condition in
  let insert_query = "INSERT INTO " ^ table ^ " (" ^ column ^ ") VALUES('" ^ db_value ^ "');" ^ select_query in
  if db_value = "" then -1
  else if (try Sqlite3.exec db_handle ~cb:callback select_query with Sqlite3.Error (message) -> error_exit ("Invalid handle when running query against database <" ^ db_name ^ "> : " ^ message)) <> Sqlite3.Rc.OK
  then error_exit ("Error in exec_db_get_id: "^(Sqlite3.errmsg db_handle)^"\n with SQL statement <"^select_query^">\n")
  else if !row_id > -1 then !row_id
  else if (create && (( Sqlite3.exec db_handle ~cb:callback insert_query) <> Sqlite3.Rc.OK))
  then error_exit ("Error in exec_db_get_id: "^(Sqlite3.errmsg db_handle)^"\n with SQL statement <"^insert_query^">\n")
  else !row_id

let insert_value_association db_handle db_name value_table value_column association_table association_id value =
  if value = "" then ()
  else if association_id = -1 then printf "Error: negative id in insert_value_association %s %s %s %d %s\n%!" value_table value_column association_table association_id value
  else
    let value_id = exec_db_get_id true false db_handle db_name value_table value_column value in
    let insert_query = "INSERT INTO "^association_table^" VALUES("^(string_of_int association_id)^","^(string_of_int value_id)^")" in
    let return_code = Sqlite3.exec db_handle insert_query in
    if return_code <> Sqlite3.Rc.OK && return_code <> Sqlite3.Rc.CONSTRAINT then
      printf "Error %s in insert_value_association: %s\n with SQL statement <%s>\n%!" (Sqlite3.Rc.to_string return_code) (Sqlite3.errmsg db_handle) insert_query
    else ()

let exec_db_get_url_status create db_handle db_name table url status =
  let old_status = ref (-1) in
  let callback (r : Sqlite3.row) (h: Sqlite3.headers) =
    old_status := if Array.length r > 0 then int_of_string (match r.(0) with Some s -> s | None -> "-1") else -1
  and select_query = "SELECT status FROM " ^ table ^ " WHERE url = '" ^ url ^ "'"
  and insert_query = "INSERT INTO " ^ table ^ " (url, status) VALUES('" ^ url ^ "'," ^ (string_of_int status) ^ ")"
  and update_query = "UPDATE " ^ table ^ " SET status = " ^ (string_of_int status) ^ " WHERE url = '" ^ url ^ "'" in
  if url = "" || (status <> 0 && status <> 1) then (-1)
  else if (try Sqlite3.exec db_handle ~cb:callback select_query with Sqlite3.Error (message) -> error_exit ("Invalid handle when running query against database <" ^ db_name ^ "> : " ^ message)) <> Sqlite3.Rc.OK
  then error_exit ("Error in exec_db_get_url_status: "^(Sqlite3.errmsg db_handle)^"\n with SQL statement <"^select_query^">\n")
  else if create then
    if !old_status > -1 then
      if Sqlite3.exec db_handle update_query <> Sqlite3.Rc.OK then
        error_exit ("Error in exec_db_get_url_status: "^(Sqlite3.errmsg db_handle)^"\n with SQL statement <"^update_query^">\n")
      else status
    else
      if Sqlite3.exec db_handle insert_query <> Sqlite3.Rc.OK then
        error_exit ("Error in exec_db_get_url_status: "^(Sqlite3.errmsg db_handle)^"\n with SQL statement <"^insert_query^">\n")
      else status
  else !old_status

let exec_db_order db_handle db_name statement =
  if (try Sqlite3.exec db_handle statement with Sqlite3.Error (message) -> error_exit ("Invalid handle when running query against database <"^db_name^"> : "^message)) <> Sqlite3.Rc.OK
  then printf "Error in exec_db_order: %s\n with SQL statement <%s>\n%!" (Sqlite3.errmsg db_handle) statement
  else ()


(* HTTP REQUEST FUNCTION *)
type request = Get | Post

let rec http_request_attempts_doc request_type url_string param_list attempts =
  if attempts = 0 then []
  else begin
    let message = match request_type with
                    Get -> Convenience.http_get_message url_string
                  | Post -> Convenience.http_post_message url_string param_list
    in
    try
      let body = message#response_body in
      if message#response_status <> `Ok && message#response_status <> `Not_found
      then begin
        printf "Error with %s: Response Status %s\n%!" url_string message#response_status_text;
        Unix.sleep !retry_delay;
        http_request_attempts_doc request_type url_string param_list (attempts - 1)
      end
      else begin
        let ch = new Netchannels.input_string body#value in
        let html_doc = parse ch in
        html_doc
      end
    with _ ->  begin
                printf "%s: Call Failed\n%!" url_string;
                Unix.sleep !retry_delay;
                http_request_attempts_doc request_type url_string param_list (attempts - 1)
              end
  end

let http_request_doc request_type url_string param_list =
  http_request_attempts_doc request_type url_string param_list !page_retries


(* GENERIC PARSING FUNCTIONS *)
type document_element = Type | Value

let get_elements_from_list elt_type type_name arg_name test_fun list_fun doc =
  let toggle_acc = ref true in
  let rec get_elements_from_doc doc acc =
    match doc, elt_type with
      Element (t, argl, docl), Type -> begin
                                          if t = type_name && (lowercase (try test_fun argl with _ -> "") = lowercase arg_name || arg_name = "") then toggle_acc := true else toggle_acc := false;
                                          get_elements_from_doc_list docl acc
                                        end
    | Data(s), Type -> if !toggle_acc && String.length (trim s) > 0 then (trim s)::acc else acc
    | Element (t, argl, docl), Value ->  if t = type_name && lowercase (try test_fun argl with _ -> "") = lowercase arg_name && (try list_fun argl with _-> "") <> "" then get_elements_from_doc_list docl ((list_fun argl)::acc)
                                          else get_elements_from_doc_list docl acc
    | Data(s) , Value  -> acc
  and get_elements_from_doc_list doc_list acc =
    match doc_list with
      h::t -> let acc2 = get_elements_from_doc h acc in get_elements_from_doc_list t acc2
    | [] -> acc
  in
  let l = get_elements_from_doc_list doc [] in
  if List.length l > 0 then List.rev_map (fun s -> try Netencoding.Html.decode ~in_enc:`Enc_utf8 ~out_enc:`Enc_utf8 () s with _ -> (printf "HTML decoding error, skipping decoding for string <%s>%!" s; s)) l else [""]

let get_elements elt_type type_name arg_name doc =
   get_elements_from_list elt_type type_name arg_name (fun l -> snd (List.hd l)) (fun l -> trim (snd (List.nth l 1))) doc

let get_content start_tokens ignore_tokens stop_tokens doc =
  let toggle_acc = ref false
  and toggle_script = ref true in (* false if within a script *)
  let rec get_content_from_doc doc acc =
    match doc with
   (* starting divs *)
      Element ("div", ah::at , dh::dt ) when (List.exists (fun s -> if s = ah then true else false) start_tokens) -> toggle_acc := true; toggle_script := true; let acc2 = get_content_from_doc dh acc in get_content_from_doc_list dt acc2
    |  Element ("div", ah::at, []) when (List.exists (fun s -> if s = ah then true else false) start_tokens) -> toggle_acc := true; toggle_script := true; acc
    (* ignore formatting div *)
    | Element ("div", ah::at , d) when (List.exists (fun s -> if s = fst ah || s = snd ah then true else false) ignore_tokens) -> toggle_script := true; get_content_from_doc_list d acc
    (* stop accumulating if stopper *)
    | Element ( _ , ah::at , d) when (List.exists (fun s -> if s = fst ah || s = snd ah then true else false) stop_tokens) -> toggle_acc := false; toggle_script := true; get_content_from_doc_list d acc
    (* ignore empty divs *)
    | Element ("div", [] , d) -> toggle_script := true; get_content_from_doc_list d acc
    (* any other div or script is a stopper when accumulating *)
    | Element ("div", _ , d) when !toggle_acc -> toggle_acc := false; toggle_script := true;  get_content_from_doc_list d acc
    (* any script is a ignored *)
    | Element ("script", _ , _ ) when !toggle_acc -> toggle_script := false; acc
    (* otherwise keep digging *)
    | Element ( _ , _ , d) ->  toggle_script := true; get_content_from_doc_list d acc
    | Data (s) when !toggle_acc && !toggle_script -> s::acc
    | Data (s) -> acc
  and get_content_from_doc_list doc_list acc =
    match doc_list with
      h::t -> let acc2 = get_content_from_doc h acc in get_content_from_doc_list t acc2
    | [] -> acc
  in
 let l = get_content_from_doc_list doc [] in
  if List.length l > 0
  then List.filter (fun s -> if length s > 0 then true else false) (List.rev_map (fun s -> trim (try Netencoding.Html.decode ~in_enc:`Enc_utf8 ~out_enc:`Enc_utf8 () s with _ -> (printf "HTML decoding error, skipping decoding for string <%s>%!" s; trim s))) l)
  else [""]


(* INITIALIZATION *)
let initialize_db db_name =
  let open_db =
    let handle = Sqlite3.db_open db_name in
    printf "Opening database %s\n%!" db_name;
    try (if Sqlite3.errcode handle <> Sqlite3.Rc.OK then error_exit ("Problem opening database <"^db_name^"> : "^(Sqlite3.errmsg handle)) else handle) with
    Sqlite3.Error (message) -> error_exit ("Invalid handle when opening database <"^db_name^"> : "^message)
  in
  let db_handle = open_db in
  let create_table order =
    exec_db_order db_handle db_name ("CREATE TABLE IF NOT EXISTS " ^ order)
  and insert_blog club name home_url home_rss =
    let insert_query = "INSERT INTO blogs(club, name, home_url, home_rss) VALUES('" ^ club ^ "',\"" ^ name ^ "\",'" ^ home_url ^ "','" ^ home_rss ^ "')" in
    let return_code = Sqlite3.exec db_handle insert_query in
    if return_code <> Sqlite3.Rc.OK && return_code <> Sqlite3.Rc.CONSTRAINT then
      printf "Error %s in insert_blog: %s\n with SQL statement <%s>\n%!" (Sqlite3.Rc.to_string return_code) (Sqlite3.errmsg db_handle) insert_query
    else ()
  in
  let rec insert_blogs blog_list =
    match blog_list with
      h::t -> insert_blog h.feed_club h.feed_name h.feed_url h.feed_rss; insert_blogs t
    | _ -> ()
  in   
  let tables = [
      "blogs (id INTEGER PRIMARY KEY AUTOINCREMENT, club TEXT, name TEXT, home_url TEXT UNIQUE COLLATE NOCASE, home_rss TXT UNIQUE COLLATE NOCASE)";
      "entries (id INTEGER PRIMARY KEY AUTOINCREMENT, blog_id INTEGER REFERENCES blogs_(id), entry_link TEXT UNIQUE COLLATE NOCASE, entry_title TEXT, entry_date TEXT, entry_seconds INTEGER, crawl_seconds INTEGER)"
    ] in
  begin
    List.iter create_table tables;
    insert_blogs feeds;
    db_handle
  end


let process_blog_feed db_handle db_name url_string =
  let insert_entry link date title =
    let blog_id = ref (-1)
    and home_url = ref ""
    and select_query = "SELECT id, home_url FROM blogs WHERE home_rss = '" ^ url_string ^ "'" in
    let callback (r : Sqlite3.row) (h: Sqlite3.headers) =
      blog_id := if Array.length r > 0 then int_of_string (match r.(0) with Some s -> s | None -> "-1") else -1;
      home_url := if Array.length r > 1 then match r.(1) with Some s -> s | None -> "UNKNOWN" else "UNKNOWN"
    in
    if (try Sqlite3.exec db_handle ~cb:callback select_query with Sqlite3.Error (message) -> error_exit ("Invalid handle when running query against database <" ^ db_name ^ "> : " ^ message)) <> Sqlite3.Rc.OK
    then error_exit ("Error in insert_entry: "^(Sqlite3.errmsg db_handle)^"\n with SQL statement <"^select_query^">\n")
    else if !blog_id >= 0 && not (exists !home_url link) && not (exists url_string link) then begin
      let entry_date = if contains date 'T' && not (starts_with date "T") then slice ~last:19 (replace_chars (fun c -> if c = 'T' then " " else of_char c) date) else date in
      let crawl_seconds = Unix.time () |> int_of_float |> string_of_int in
      let entry_seconds = try (entry_date |> Netdate.parse_epoch |> int_of_float |> string_of_int) with _ -> crawl_seconds in
      let entry_tile = replace_chars (fun c -> if c = '"' then "" else of_char c) title
      in
      let insert_query = "INSERT INTO entries(blog_id, entry_link, entry_title, entry_date, entry_seconds, crawl_seconds) VALUES(" ^ (string_of_int !blog_id) ^ ",'" ^ link ^ "',\"" ^ entry_tile ^ "\",'" ^ entry_date ^ "'," ^ entry_seconds ^ "," ^ crawl_seconds ^ ")" in
      let return_code = Sqlite3.exec db_handle insert_query in
      if return_code <> Sqlite3.Rc.OK && return_code <> Sqlite3.Rc.CONSTRAINT then
        printf "Error %s in insert_entry: %s\n with SQL statement <%s>\n%!" (Sqlite3.Rc.to_string return_code) (Sqlite3.errmsg db_handle) insert_query
      else ()
    end
    else ()
  in
  let rec process_links links dates titles =
    match links,dates,titles with
      h_l::t_l, h_d::t_d, h_t::t_t -> insert_entry h_l h_d h_t; process_links t_l t_d t_t
    | _ -> ()
  in
  let url = parse_url url_string in
  let doc = http_request_doc Get (string_of_url url) [] in
  let rss_links = get_elements_from_list Value "link" "alternate" (fun l -> trim (snd (List.find (fun x -> lowercase (fst x) = "rel") l))) (fun l -> trim (snd (List.find (fun x -> lowercase (fst x) = "href") l))) doc in
  let atom_links = get_elements Type "link" "" doc in
  let atom_dates = get_elements Type "pubdate" "" doc in
  let atom_titles = get_elements Type "title" "" doc in
  let blogspot_dates = if List.length (get_elements Type "updated" "" doc) > 0 then get_elements Type "updated" "" doc else get_elements Type "published" "" doc in
  let arsenal_mania_dates = get_elements Type "dc:date" "" doc in
  let links = List.append rss_links atom_links |> List.append arsenal_mania_dates |> List.filter (fun s -> s <> "")
  and dates = List.append atom_dates blogspot_dates |> List.filter (fun s -> s <> "")
  and titles = atom_titles |> List.filter (fun s -> s <> "")
  in
  if List.length dates > 0 && List.length dates <= List.length links && List.length dates <= List.length titles then begin
    let final_links = if List.length dates < List.length links then (links |> List.rev |> List.drop (List.length links - List.length dates)) else (links |> List.rev)
    and final_titles = if List.length dates < List.length titles then (titles |> List.rev |> List.drop (List.length titles - List.length dates)) else (titles |> List.rev)
    in
    process_links final_links (dates |> List.rev) final_titles;
  end


(*  printf "%d %d %d\n%!" (List.length links) (List.length dates) (List.length titles)
  ignore (List.map (printf "link: %s \n") links);
  ignore (List.map (printf "dates: %s \n") dates);
  ignore (List.map (printf "titles: %s \n") titles)*)
  

let crawl_blogs_rss db_handle db_name club =
  printf "CLUB %s\n%!" club;
  let process_feed (r : Sqlite3.row) (h: Sqlite3.headers) =
    let feed = if Array.length r > 0 then match r.(0) with Some s -> s | None -> "" else "" in
    if is_invalid_url feed then
      printf "Error: %s is an invalid feed URL\n%!" feed
    else begin
      printf "Feed: %s\n%!" feed;
      process_blog_feed db_handle db_name feed
    end
  in
  let query = "SELECT home_rss FROM blogs WHERE club = '" ^ club ^ "'" in
  if (try Sqlite3.exec db_handle ~cb:process_feed query with Sqlite3.Error (message) -> error_exit ("Errors when running query against database <" ^ db_name ^ "> : " ^ message)) <> Sqlite3.Rc.OK
  then error_exit ("Error in crawl_blogs_rss: "^(Sqlite3.errmsg db_handle)^"\n with SQL statement <"^query^">\n")

let save_entries db_handle db_name nb_entries club =
  let count = ref 0 in
  let chan = open_out ((replace_chars ((fun c -> if c = ' ' then "_" else of_char c)) club) ^ ".json") in
  let query = if starts_with club "Ars" || starts_with club "Liv" || starts_with club "Man"
  then "select name, home_url, entry_title, entry_link from blogs join (select blog_id, max(id) as maxid from entries group by blog_id) ent2 on blogs.id = ent2.blog_id join entries on blogs.id = entries.blog_id and ent2.maxid = entries.id where club = '" ^ club ^ "' order by min(entry_seconds,  crawl_seconds) desc limit " ^ (of_int nb_entries)
  else "select name, home_url, entry_title, entry_link from blogs join entries on blogs.id = entries.blog_id where club = '" ^ club ^ "' order by min(entry_seconds,  crawl_seconds) desc limit " ^ (of_int nb_entries) in
  let write_json (r : Sqlite3.row) (h: Sqlite3.headers) =
    let name = if Array.length r > 0 then match r.(0) with Some s -> s | None -> "" else ""
    and home_url = if Array.length r > 1 then match r.(1) with Some s -> s | None -> "" else ""
    and entry_title = if Array.length r > 2 then match r.(2) with Some s -> s | None -> "" else ""
    and entry_link = if Array.length r > 3 then match r.(3) with Some s -> s | None -> "" else ""
    in
    incr count;
    output_string chan ("{ \"blog_name\": \"" ^ name ^ "\", \"blog_url\": \"" ^ home_url ^ "\", \"entry_title\": \"" ^entry_title  ^ "\", \"entry_url\": \"" ^ entry_link ^ "\"}" ^ (if !count < nb_entries then "," else "") ^ "\n")
  in
  output_string chan ("var club_blogs_entries = [\n");
  if (try Sqlite3.exec db_handle ~cb:write_json query with Sqlite3.Error (message) -> error_exit ("Errors when running query against database <" ^ db_name ^ "> : " ^ message)) <> Sqlite3.Rc.OK
  then error_exit ("Error in save_entries: "^(Sqlite3.errmsg db_handle)^"\n with SQL statement <"^query^">\n");
  output_string chan "];\n";
  close_out chan

let () =
  let opt_parser = OptParser.make ~prog:"crawler" ~usage:("footballcrawler [-cCLUB] [-eENTRIES] [-dDB]") ~version:"1.0" ()
  and club_opt = StdOpt.str_option ~metavar:"CLUB" ~default:"" ()
  and nb_entries_opt = StdOpt.int_option ~metavar:"NBENTRIES" ~default:default_nb_links ()
  and db_opt = StdOpt.str_option ~metavar:"DB" ~default:default_db_name ()
  in
  OptParser.add ~short_name:'c' ~long_name:"club" ~help:"club: a/arsenal l/liverpool m/manu n/newcastle t/totthenham" opt_parser club_opt;
  OptParser.add ~short_name:'e' ~long_name:"entries" ~help:("number of blog entries requested (default: " ^ (string_of_int default_nb_links) ^ ")") opt_parser nb_entries_opt;
  OptParser.add ~short_name:'d' ~long_name:"db" ~help:("database name (default: " ^ default_db_name ^ ")") opt_parser db_opt;
  ignore (OptParser.parse_argv opt_parser);
  let club = if length (Opt.get club_opt) > 0 then lowercase (sub (Opt.get club_opt) 0 1) else ""
  and nb_entries = Opt.get nb_entries_opt
  and db_name = Opt.get db_opt
  in
  let clubs = 
    if club = "a" then ["Arsenal"]
    else if club = "l" then ["Liverpool"]
    else if club = "m" then ["Manchester United"]
    else if club = "n" then ["Newcastle United"]
    else if club = "t" then ["Tottenham Hotspur"]
    else ["Arsenal"; "Liverpool"; "Manchester United"; "Newcastle United"; "Tottenham Hotspur"]
  in
  let db_handle = initialize_db db_name in
(*     process_blog_feed db_handle db_name "http://feeds.feedburner.com/N7teen"; *)
    List.iter (crawl_blogs_rss db_handle db_name) clubs;
    List.iter (save_entries db_handle db_name nb_entries) clubs;
  close_db db_handle db_name