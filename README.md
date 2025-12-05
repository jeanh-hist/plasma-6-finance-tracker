# plasma-6-finance-tracker
Plasma 6 Finance Tracker based on Yahoo Finance
By: Jean Viana

I ain't really a coding guy so it might be hella bugged. Did so because I missed a stock tracker as I used to have on Cinnamon.
Feel free to make changes, comments and whatever.

How to install:

By KDE:

1. open edit mode 
2. "add or manage widgets" > obtain new widgets > search "Plasma 6 Finance Tracker" > install
3. add the Finance tracker widget on the desktop
4. open configs and add your tickers

Semi-manual install:

1. download the kde-finance-tracker tar.gz
2. extract it anywhere
3. run install.sh
4. open edit mode
5. add the Finance Tracker widget
6. open configs and add your tickers

Manual install:

1. download the kde-finance-tracker tar.gz
2. create a folder on ~/.local/share/plasma/plasmoids named "org.kde.plasma.financetracker"
3. extract the files on ~/.local/share/plasma/plasmoids/org.kde.plasma.financetracker
4. open terminal and run [kpackagetool6 --type Plasma/Applet --upgrade] and then [kquitapp6 plasmashell && kstart plasmashell &]
5. open edit mode
6. add the Finance Tracker widget
7. open configs and add your tickers
