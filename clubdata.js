var clubMap = {
    live : "Liverpool"
,   pool : "Liverpool"
,   manc : "Manchester"
,   manu : "Manchester"
,   arse : "Arsenal"
,   goon : "Arsenal"
,   spur : "Spurs"
,   tott : "Spurs"
,   newc : "Newcastle"
,   toon : "Newcastle"
}

var clubs = {} ;

var std_layout = [ ['fanBlogs','Buzz'],   ['News', 'News', 'Manager'],  ['BBC','Telegraph','Guardian'], ['Espn','SkySports'] ];

function layoutExtender(layout){
    var instanceLayout = layout;
    return function(v,i,a) {
        return v.concat(instanceLayout[i]);
    }
}

clubs.Arsenal = {
        name : "Arsenal"
    ,   file : "Arsenal.json"
    ,   keywords : "Arsenal News,Arsenal,Arsenal FC,AFC,Arsenal Football Club,Wenger,Arsenal Results,Arsenal Fixtures,Gunners,Arsenal Rumors,Arsenal Rumours,Arsenal Transfers,Emirates Stadium"
    ,   blogcatalog : "9BC9359662"
    ,   content: [
            { name: 'News',         count: 5,   renderer: 'withImage',  URL: "http://news.google.com/news?um=1&ned=uk&hl=en&q=arsenal&output=rss"}
        ,   { name: 'Buzz',         count: 4,   renderer: 'doubleWide', URL: "http://blogsearch.google.com/blogsearch_feeds?q=arsenal&oe=utf-8&client=firefox-a&um=1&hl=en&ie=utf-8&num=10&output=rss" }
        ,   { name: 'Tweets',       count: 5,   renderer: 'noSnippet',  URL: "http://search.twitter.com/search.atom?q=arsenal"  }
        ,   { name: 'Manager',      count: 5,                           URL: "http://news.google.com/news?um=1&ned=uk&hl=en&q=wenger&output=rss" }
        ,   { name: 'BBC',          count: 6,                           URL: "http://newsrss.bbc.co.uk/rss/sportonline_world_edition/football/teams/a/arsenal/rss.xml" }
//      ,   { name: 'youtube',      count: 4,   renderer: 'youtube',    URL: "http://gdata.youtube.com/feeds/base/videos/-/arsenalfc?client=ytapi-youtube-browse&v=2" }
        ,   { name: 'Telegraph',    count: 5,                           URL: "http://www.telegraph.co.uk/sport/football/leagues/premierleague/arsenal/rss"}
        ,   { name: 'Guardian',     count: 5,                           URL: "http://www.guardian.co.uk/football/arsenal/rss"}
        ,   { name: 'Official',     count: 7,                           URL: "http://www.arsenal.com/rssfeed" }
        ,   { name: 'Yahoo',        count: 5,                           URL: "http://uk.eurosport.yahoo.com/football/arsenal/index.html.xml"}
        ,   { name: 'Espn',         count: 5,                           URL: "http://blogs.soccernet.com/arsenal/index.xml"}
        ,   { name: 'SkySports',    count: 5,                           URL: "http://www.skysports.com/rss/0,20514,11670,00.xml"}
        ]
    ,   layout : std_layout.map(layoutExtender([['fanBlogs'],[],[],['Official']]))
    ,   flicker : "gooners"
    ,   links : [
            "<a class='articleLink' href='http://www.arsenal.com'>Arsenal Football Club Official Website</a><br/>"
        ,   "<a class='articleLink' href='http://www.premierleague.com/page/Arsenal'>Premier League : Arsenal</a><br/>"
        ,   "<a class='articleLink' href=' http://en.wikipedia.org/wiki/Arsenal_F.C.'>Wikipedia : Arsenal</a>"
        ]
    };

clubs.Manchester = {
        name : "Manchester United"
    ,   file : "Manchester_United.json"
    ,   keywords : "Manchester United,Man Utd,Man U,MU,MUFC,Man United,Red Devils,Reds,Old Trafford,Treble,Ferguson,Alex Ferguson,Sir Alex,Manchester Results,Manchester Fixtures,Manchester Rumors,Manchester Rumours,Manchester Transfers"
    ,   blogcatalog : "9BC9359682"
    ,   content: [
            { name: 'News',         count: 5,   renderer: 'withImage',  URL: "http://news.google.com/news?um=1&ned=uk&hl=en&q=Manchester%20United&output=rss"}
        ,   { name: 'EveningNews',  count: 5,   renderer: 'withImage',  URL: "http://feeds.manchestereveningnews.co.uk/co/MwdI" }
        ,   { name: 'Buzz',         count: 4,                           URL: "http://blogsearch.google.com/blogsearch_feeds?q=Manchester%20United&oe=utf-8&client=firefox-a&um=1&hl=en&ie=utf-8&num=10&output=rss" }
        ,   { name: 'Tweets',       count: 4,   renderer: 'noSnippet',  URL: "http://search.twitter.com/search.atom?q=Manchester%20United"  }
        ,   { name: 'Manager',      count: 5,                           URL: "http://news.google.com/news?um=1&ned=uk&hl=en&q=alex+ferguson&output=rss" }
        ,   { name: 'BBC',          count: 7,                           URL: "http://newsrss.bbc.co.uk/rss/sportonline_world_edition/football/teams/m/man_utd/rss.xml" }
        ,   { name: 'youtube',      count: 4,   renderer: 'youtube',    URL: "http://gdata.youtube.com/feeds/base/videos/-/manchesterunited?client=ytapi-youtube-browse&v=2" }
        ,   { name: 'Telegraph',    count: 5,                           URL: "http://www.telegraph.co.uk/sport/football/leagues/premierleague/manutd/rss"}
        ,   { name: 'Guardian',     count: 5,                           URL: "http://www.guardian.co.uk/football/manchesterunited/rss"}
        ,   { name: 'Official',     count: 5,                           URL: "http://www.manutd.com/default.sps?pagegid={6999B94A-B2C5-4014-878A-615462276B43}" }
        ,   { name: 'Yahoo',        count: 5,                           URL: "http://uk.eurosport.yahoo.com/football/manchester-united/index.html.xml"}
        ,   { name: 'Espn',         count: 5,                           URL: "http://blogs.soccernet.com/manchesterunited/index.xml"}
        ,   { name: 'SkySports',    count: 5,                           URL: "http://www.skysports.com/rss/0,20514,11667,00.xml"}

        ]
    ,   layout :  [ ['fanBlogs','fanBlogs','Buzz'], ['EveningNews','News' ], ['Manager','BBC','Telegraph'], ['Guardian','Espn','SkySports'] ]
    ,   flicker : "manchesterunited"
    ,   links : [
            "<a class='articleLink' href='http://www.manutd.com'>Manchester United Football Club Official Website</a><br/>"
        ,   "<a class='articleLink' href='http://www.premierleague.com/page/manchester-united'>Premier League : Manchester United</a><br/>"
        ,   "<a class='articleLink' href=' http://en.wikipedia.org/wiki/Manchester_United_F.C.'>Wikipedia : Manchester United</a>"
        ]
    }

clubs.Liverpool = {
        name : "Liverpool"
    ,   file : "Liverpool.json"
    ,   keywords : "Liverpool News,Liverpool,Liverpool FC,LFC,Liverpool Football Club,Reds,Anfield,Benitez,Rafael Benitez,Rafa Benitez,Liverpool Results,Liverpool Fixtures,Liverpool Rumors,Liverpool Rumours,Liverpool Transfer,Liverpool Transfers"
    ,   blogcatalog : "9BC9359676"
    ,   content: [
            { name: 'News',         count: 5,   renderer: 'withImage',  URL: "http://news.google.com/news?um=1&ned=uk&hl=en&q=liverpool&output=rss"}
        ,   { name: 'Buzz',         count: 4,                           URL: "http://blogsearch.google.com/blogsearch_feeds?q=liverpool&oe=utf-8&client=firefox-a&um=1&hl=en&ie=utf-8&num=10&output=rss" }
        ,   { name: 'Echo',         count: 5,                           URL: "http://www.liverpoolecho.co.uk/liverpool-fc/liverpool-fc-news/rss.xml" }
        ,   { name: 'DailyPost',    count: 5,                           URL: "http://www.liverpooldailypost.co.uk/liverpool-fc/rss.xml" }
//      ,   { name: 'youtube',      count: 4,   renderer: 'youtube',    URL: "http://gdata.youtube.com/feeds/base/videos/-/liverpoolfc?client=ytapi-youtube-browse&v=2" }
        ,   { name: 'Tweets',       count: 6,   renderer: 'noSnippet',  URL: "http://search.twitter.com/search.atom?q=liverpool"  }
        ,   { name: 'Manager',      count: 5,                           URL: "http://news.google.com/news?um=1&ned=uk&hl=en&q=rafa+benitez&output=rss" }
        ,   { name: 'BBC',          count: 5,                           URL: "http://newsrss.bbc.co.uk/rss/sportonline_world_edition/football/teams/l/liverpool/rss.xml" }
        ,   { name: 'Telegraph',    count: 5,                           URL: "http://www.telegraph.co.uk/sport/football/leagues/premierleague/liverpool/rss"}
        ,   { name: 'Guardian',     count: 5,                           URL: "http://www.guardian.co.uk/football/liverpool/rss"}
        ,   { name: 'Yahoo',        count: 5,                           URL: "http://uk.eurosport.yahoo.com/football/liverpool/index.html.xml"}
        ,   { name: 'Espn',         count: 5,                           URL: "http://blogs.soccernet.com/liverpool/index.xml"}
        ,   { name: 'SkySports',    count: 5,                           URL: "hhttp://www.skysports.com/rss/0,20514,11669,00.xml"}
        ]
    ,   layout : [ ['fanBlogs','fanBlogs','Buzz'], ['News','News','Echo'], ['Manager','BBC','Telegraph'], ['Guardian','Espn' ] ]
    ,   flicker : "liverpoolfc"
    ,   links : [
            "<a class='articleLink' href='http://www.liverpoolfc.tv/'>Liverpool Football Club Official Website</a><br/>"
        ,   "<a class='articleLink' href='http://www.premierleague.com/page/Liverpool'>Premier League : Liverpool</a><br/>"
        ,   "<a class='articleLink' href=' http://en.wikipedia.org/wiki/Liverpool_F.C.'>Wikipedia : Liverpool</a>"
        ]
    };

clubs.Newcastle = {
        name : "Newcastle"
    ,   file : "Newcastle_United.json"
    ,   keywords : ""
    ,   content: [
            { name: 'News',         count: 5,   renderer: 'withImage',  URL: "http://news.google.com/news?um=1&ned=uk&hl=en&q=newcastle+united&output=rss"}
        ,   { name: 'Chronicle',    count: 5,                           URL: "http://www.chroniclelive.co.uk/nufc/newcastle-united-news/rss.xml" }
        ,   { name: 'Tweets',       count: 6,   renderer: 'noSnippet',  URL: "http://search.twitter.com/search.atom?q=newcastle"  }
        ,   { name: 'Manager',      count: 5,                           URL: "http://news.google.com/news?um=1&ned=uk&hl=en&q=alan+pardew&output=rss" }
        ,   { name: 'Shearer',      count: 5,                           URL: "http://news.google.com/news?um=1&ned=uk&hl=en&q=alan+shearer&output=rss" }
        ,   { name: 'BBC',          count: 5,                           URL: "http://newsrss.bbc.co.uk/rss/sportonline_world_edition/football/teams/n/newcastle_united/rss.xml" }
        ,   { name: 'Telegraph',    count: 5,                           URL: "http://www.telegraph.co.uk/sport/football/leagues/championship/newcastleunited/rss"}
        ,   { name: 'Guardian',     count: 5,                           URL: "http://feeds.guardian.co.uk/theguardian/football/newcastleunited/rss"}
        ,   { name: 'Buzz',         count: 5,                           URL: "http://blogsearch.google.com/blogsearch_feeds?q=newcastle+united&oe=utf-8&client=firefox-a&um=1&hl=en&ie=utf-8&num=10&output=rss" }
        ,   { name: 'Yahoo',        count: 5,                           URL: "http://uk.eurosport.yahoo.com/football/newcastle-united/index.html.xml"}
        ,   { name: 'Espn',         count: 5,                           URL: "http://search.espn.go.com/rss/newcastle-united/"}
        ,   { name: 'SkySports',    count: 5,                           URL: "http://www.skysports.com/rss/0,20514,11678,00.xml"}
        ]
//  ,   layout : [ ['fanBlogs','Buzz'],['News', 'News', 'Manager'],['BBC','Chronicle','Guardian'],['Shearer','Espn','SkySports'] ]
    ,   layout : [ ['Buzz', 'News'],['BBC','Chronicle'],['Shearer','Espn'],['SkySports','Guardian'] ]
    ,   flicker : "newcastleunited"
    ,   links : [
            "<a class='articleLink' href='http://www.liverpoolfc.tv/'>Liverpool Football Club Official Website</a><br/>"
        ,   "<a class='articleLink' href='http://www.premierleague.com/page/Liverpool'>Premier League : Liverpool</a><br/>"
        ,   "<a class='articleLink' href=' http://en.wikipedia.org/wiki/Liverpool_F.C.'>Wikipedia : Liverpool</a>"
        ]
    };

 clubs.Spurs = {
        name : "Tottenham"
    ,   file : "Tottenham_Hotspur.json"
    ,   keywords : ""
    ,   content: [
            { name: 'News',         count: 5,   renderer: 'withImage',  URL: "http://news.google.com/news?um=1&ned=uk&hl=en&q=Tottenham+hotspur&output=rss"}
//      ,   { name: 'RSS',          count: 2,   renderer: 'story',      URL: "http://feeds.guardian.co.uk/theguardian/football/TottenhamHotspur/rss" }
        ,   { name: 'Blogs',        count: 12,                          URL: "http://blogsearch.google.com/blogsearch_feeds?q=tottenham+hotspur&oe=utf-8&client=firefox-a&um=1&hl=en&ie=utf-8&num=10&output=rss" }
        ,   { name: 'Tweets',       count: 10,  renderer: 'noSnippet',  URL: "http://search.twitter.com/search.atom?q=tottenham"  }
        ,   { name: 'Manager',      count: 5,                           URL: "http://news.google.com/news?um=1&ned=uk&hl=en&q=harry+redknapp&output=rss" }
        ,   { name: 'BBC',          count: 5,                           URL: "http://newsrss.bbc.co.uk/rss/sportonline_world_edition/football/teams/t/tottenham_hotspur/rss.xml" }
        ,   { name: 'Telegraph',    count: 5,                           URL: "http://www.telegraph.co.uk/sport/football/leagues/premierleague/tottenham/rss"}
        ,   { name: 'Guardian',     count: 5,                           URL: "http://feeds.guardian.co.uk/theguardian/football/tottenham-hotspur/rss"}
        ,   { name: 'Yahoo',        count: 5,                           URL: "http://uk.eurosport.yahoo.com/football/tottenham-hotspur/index.html.xml"}
        ,   { name: 'Buzz',         count: 5,   renderer: 'doubleWide', URL: "http://blogsearch.google.com/blogsearch_feeds?q=tottenham&oe=utf-8&client=firefox-a&um=1&hl=en&ie=utf-8&num=10&output=rss" }
        ,   { name: 'Espn',         count: 5,                           URL: "http://blogs.soccernet.com/tottenhamhotspur/index.xml"}
        ,   { name: 'SkySports',    count: 5,                           URL: "http://www.skysports.com/rss/0,20514,11675,00.xml"}
        ]
    ,   layout : std_layout
    ,   flicker : "Spurs"
    ,   links : [
            "<a class='articleLink' href='http://www.liverpoolfc.tv/'>Liverpool Football Club Official Website</a><br/>"
        ,   "<a class='articleLink' href='http://www.premierleague.com/page/Liverpool'>Premier League : Liverpool</a><br/>"
        ,   "<a class='articleLink' href=' http://en.wikipedia.org/wiki/Liverpool_F.C.'>Wikipedia : Liverpool</a>"
        ]
    };

