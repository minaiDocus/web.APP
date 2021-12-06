# -*- encoding : UTF-8 -*-
require 'net/ftp'

class Ftp::Fetcher
  # FILENAME_PATTERN = /\A#{Pack::CODE_PATTERN}(_| )#{Pack::JOURNAL_PATTERN}(_| )#{Pack::PERIOD_PATTERN}(_| )#{Pack::POSITION_PATTERN}#{Pack::EXTENSION_PATTERN}\z/
  FILENAME_PATTERN = /\A#{Pack::CODE_PATTERN}(_| )#{Pack::JOURNAL_PATTERN}(_| )#{Pack::PERIOD_PATTERN}(_| )page\d{3,4}#{Pack::EXTENSION_PATTERN}\z/

  def self.fetch(url, username, password, dir = '/', provider = '')
    include_pack = ['CEN%0374 AC 202109','CEN%0503 AC 202110','CEN%0761 AC 202108','CEN%0761 AC 202109','CEN%1380 AC 202108','CEN%1380 AC 202109','CEN%5732 AC 202109','CEN%5732 VE 202109','CEN%5861 AC 202109','CEN%6307 AC 202107','CEN%6307 VE 202107','CEN%6307 VE 202109','CEN%6352 AC 202109','CEN%6352 VE 202109','CEN%M057 AC 202110','CEN%M150 AC 202110','CEN%N077 AC 202110']

    exclude_files = ['CEN%0374 AC 202109_page0002.PDF','CEN%0374 AC 202109_page0006.PDF','CEN%0374 AC 202109_page0010.PDF','CEN%0374 AC 202109_page0011.PDF','CEN%0374 AC 202109_page0013.PDF','CEN%0374 AC 202109_page0014.PDF','CEN%0374 AC 202109_page0020.PDF','CEN%0374 AC 202109_page0024.PDF','CEN%0374 AC 202109_page0026.PDF','CEN%0374 AC 202109_page0027.PDF','CEN%0374 AC 202109_page0033.PDF','CEN%0374 AC 202109_page0035.PDF','CEN%0374 AC 202109_page0036.PDF','CEN%0374 AC 202109_page0037.PDF','CEN%0374 AC 202109_page0040.PDF','CEN%0374 AC 202109_page0042.PDF','CEN%0374 AC 202109_page0047.PDF','CEN%0374 AC 202109_page0049.PDF','CEN%0374 AC 202109_page0052.PDF','CEN%0374 AC 202109_page0053.PDF','CEN%0374 AC 202109_page0054.PDF','CEN%0374 AC 202109_page0055.PDF','CEN%0374 AC 202109_page0060.PDF','CEN%0374 AC 202109_page0063.PDF','CEN%0374 AC 202109_page0066.PDF','CEN%0374 AC 202109_page0070.PDF','CEN%0374 AC 202109_page0071.PDF','CEN%0374 AC 202109_page0072.PDF','CEN%0374 AC 202109_page0074.PDF','CEN%0374 AC 202109_page0076.PDF','CEN%0374 AC 202109_page0081.PDF','CEN%0374 AC 202109_page0085.PDF','CEN%0374 AC 202109_page0091.PDF','CEN%0374 AC 202109_page0094.PDF','CEN%0374 AC 202109_page0097.PDF','CEN%0374 AC 202109_page0098.PDF','CEN%0374 AC 202109_page0101.PDF','CEN%0374 AC 202109_page0102.PDF','CEN%0374 AC 202109_page0103.PDF','CEN%0374 AC 202109_page0106.PDF','CEN%0374 AC 202109_page0113.PDF','CEN%0374 AC 202109_page0114.PDF','CEN%0374 AC 202109_page0116.PDF','CEN%0374 AC 202109_page0123.PDF','CEN%0374 AC 202109_page0124.PDF','CEN%0374 AC 202109_page0128.PDF','CEN%0374 AC 202109_page0130.PDF','CEN%0374 AC 202109_page0131.PDF','CEN%0374 AC 202109_page0134.PDF','CEN%0374 AC 202109_page0135.PDF','CEN%0374 AC 202109_page0139.PDF','CEN%0374 AC 202109_page0143.PDF','CEN%0374 AC 202109_page0147.PDF','CEN%0374 AC 202109_page0148.PDF','CEN%0374 AC 202109_page0153.PDF','CEN%0374 AC 202109_page0155.PDF','CEN%0374 AC 202109_page0157.PDF','CEN%0374 AC 202109_page0160.PDF','CEN%0374 AC 202109_page0177.PDF','CEN%0374 AC 202109_page0178.PDF','CEN%0374 AC 202109_page0179.PDF','CEN%0374 AC 202109_page0187.PDF','CEN%0374 AC 202109_page0191.PDF','CEN%0374 AC 202109_page0198.PDF','CEN%0374 AC 202109_page0199.PDF','CEN%0374 AC 202109_page0203.PDF','CEN%0374 AC 202109_page0204.PDF','CEN%0374 AC 202109_page0205.PDF','CEN%0374 AC 202109_page0207.PDF','CEN%0374 AC 202109_page0209.PDF','CEN%0503 AC 202110_page0001.PDF','CEN%0503 AC 202110_page0003.PDF','CEN%0503 AC 202110_page0004.PDF','CEN%0503 AC 202110_page0009.PDF','CEN%0503 AC 202110_page0011.PDF','CEN%0503 AC 202110_page0015.PDF','CEN%0503 AC 202110_page0018.PDF','CEN%0503 AC 202110_page0020.PDF','CEN%0503 AC 202110_page0023.PDF','CEN%0503 AC 202110_page0025.PDF','CEN%0503 AC 202110_page0029.PDF','CEN%0503 AC 202110_page0030.PDF','CEN%0503 AC 202110_page0034.PDF','CEN%0503 AC 202110_page0036.PDF','CEN%0761 AC 202108_page0002.PDF','CEN%0761 AC 202108_page0006.PDF','CEN%0761 AC 202108_page0007.PDF','CEN%0761 AC 202108_page0008.PDF','CEN%0761 AC 202108_page0012.PDF','CEN%0761 AC 202108_page0018.PDF','CEN%0761 AC 202108_page0019.PDF','CEN%0761 AC 202108_page0023.PDF','CEN%0761 AC 202108_page0024.PDF','CEN%0761 AC 202108_page0025.PDF','CEN%0761 AC 202108_page0027.PDF','CEN%0761 AC 202108_page0028.PDF','CEN%0761 AC 202108_page0031.PDF','CEN%0761 AC 202108_page0034.PDF','CEN%0761 AC 202108_page0038.PDF','CEN%0761 AC 202108_page0039.PDF','CEN%0761 AC 202108_page0042.PDF','CEN%0761 AC 202108_page0044.PDF','CEN%0761 AC 202108_page0045.PDF','CEN%0761 AC 202108_page0047.PDF','CEN%0761 AC 202108_page0048.PDF','CEN%0761 AC 202108_page0049.PDF','CEN%0761 AC 202108_page0051.PDF','CEN%0761 AC 202108_page0054.PDF','CEN%0761 AC 202108_page0057.PDF','CEN%0761 AC 202108_page0062.PDF','CEN%0761 AC 202108_page0063.PDF','CEN%0761 AC 202108_page0064.PDF','CEN%0761 AC 202108_page0065.PDF','CEN%0761 AC 202108_page0066.PDF','CEN%0761 AC 202108_page0069.PDF','CEN%0761 AC 202108_page0073.PDF','CEN%0761 AC 202108_page0080.PDF','CEN%0761 AC 202108_page0082.PDF','CEN%0761 AC 202108_page0083.PDF','CEN%0761 AC 202108_page0085.PDF','CEN%0761 AC 202108_page0088.PDF','CEN%0761 AC 202108_page0089.PDF','CEN%0761 AC 202108_page0090.PDF','CEN%0761 AC 202108_page0091.PDF','CEN%0761 AC 202108_page0094.PDF','CEN%0761 AC 202108_page0096.PDF','CEN%0761 AC 202108_page0098.PDF','CEN%0761 AC 202108_page0100.PDF','CEN%0761 AC 202108_page0102.PDF','CEN%0761 AC 202108_page0104.PDF','CEN%0761 AC 202108_page0105.PDF','CEN%0761 AC 202108_page0108.PDF','CEN%0761 AC 202108_page0109.PDF','CEN%0761 AC 202108_page0110.PDF','CEN%0761 AC 202108_page0111.PDF','CEN%0761 AC 202108_page0114.PDF','CEN%0761 AC 202108_page0115.PDF','CEN%0761 AC 202108_page0117.PDF','CEN%0761 AC 202108_page0119.PDF','CEN%0761 AC 202108_page0120.PDF','CEN%0761 AC 202108_page0121.PDF','CEN%0761 AC 202108_page0123.PDF','CEN%0761 AC 202108_page0130.PDF','CEN%0761 AC 202108_page0131.PDF','CEN%0761 AC 202108_page0132.PDF','CEN%0761 AC 202108_page0135.PDF','CEN%0761 AC 202108_page0139.PDF','CEN%0761 AC 202108_page0140.PDF','CEN%0761 AC 202108_page0142.PDF','CEN%0761 AC 202108_page0146.PDF','CEN%0761 AC 202108_page0147.PDF','CEN%0761 AC 202108_page0150.PDF','CEN%0761 AC 202108_page0152.PDF','CEN%0761 AC 202108_page0161.PDF','CEN%0761 AC 202108_page0162.PDF','CEN%0761 AC 202108_page0164.PDF','CEN%0761 AC 202108_page0165.PDF','CEN%0761 AC 202108_page0166.PDF','CEN%0761 AC 202108_page0167.PDF','CEN%0761 AC 202108_page0169.PDF','CEN%0761 AC 202108_page0170.PDF','CEN%0761 AC 202108_page0172.PDF','CEN%0761 AC 202108_page0174.PDF','CEN%0761 AC 202108_page0186.PDF','CEN%0761 AC 202108_page0198.PDF','CEN%0761 AC 202108_page0201.PDF','CEN%0761 AC 202108_page0205.PDF','CEN%0761 AC 202108_page0206.PDF','CEN%0761 AC 202108_page0208.PDF','CEN%0761 AC 202108_page0214.PDF','CEN%0761 AC 202108_page0220.PDF','CEN%0761 AC 202108_page0221.PDF','CEN%0761 AC 202108_page0224.PDF','CEN%0761 AC 202108_page0225.PDF','CEN%0761 AC 202108_page0227.PDF','CEN%0761 AC 202108_page0234.PDF','CEN%0761 AC 202108_page0236.PDF','CEN%0761 AC 202108_page0237.PDF','CEN%0761 AC 202108_page0239.PDF','CEN%0761 AC 202108_page0241.PDF','CEN%0761 AC 202108_page0244.PDF','CEN%0761 AC 202109_page0005.PDF','CEN%0761 AC 202109_page0008.PDF','CEN%0761 AC 202109_page0009.PDF','CEN%0761 AC 202109_page0016.PDF','CEN%0761 AC 202109_page0017.PDF','CEN%0761 AC 202109_page0022.PDF','CEN%0761 AC 202109_page0024.PDF','CEN%0761 AC 202109_page0025.PDF','CEN%0761 AC 202109_page0026.PDF','CEN%0761 AC 202109_page0031.PDF','CEN%0761 AC 202109_page0034.PDF','CEN%0761 AC 202109_page0036.PDF','CEN%0761 AC 202109_page0041.PDF','CEN%0761 AC 202109_page0043.PDF','CEN%0761 AC 202109_page0047.PDF','CEN%0761 AC 202109_page0048.PDF','CEN%0761 AC 202109_page0053.PDF','CEN%0761 AC 202109_page0060.PDF','CEN%0761 AC 202109_page0061.PDF','CEN%0761 AC 202109_page0063.PDF','CEN%0761 AC 202109_page0065.PDF','CEN%0761 AC 202109_page0066.PDF','CEN%0761 AC 202109_page0067.PDF','CEN%0761 AC 202109_page0073.PDF','CEN%0761 AC 202109_page0074.PDF','CEN%0761 AC 202109_page0080.PDF','CEN%0761 AC 202109_page0081.PDF','CEN%0761 AC 202109_page0084.PDF','CEN%0761 AC 202109_page0085.PDF','CEN%0761 AC 202109_page0086.PDF','CEN%0761 AC 202109_page0092.PDF','CEN%0761 AC 202109_page0094.PDF','CEN%0761 AC 202109_page0095.PDF','CEN%0761 AC 202109_page0099.PDF','CEN%0761 AC 202109_page0103.PDF','CEN%0761 AC 202109_page0105.PDF','CEN%0761 AC 202109_page0109.PDF','CEN%0761 AC 202109_page0111.PDF','CEN%0761 AC 202109_page0112.PDF','CEN%0761 AC 202109_page0115.PDF','CEN%0761 AC 202109_page0120.PDF','CEN%0761 AC 202109_page0122.PDF','CEN%0761 AC 202109_page0123.PDF','CEN%0761 AC 202109_page0124.PDF','CEN%0761 AC 202109_page0126.PDF','CEN%0761 AC 202109_page0128.PDF','CEN%0761 AC 202109_page0133.PDF','CEN%0761 AC 202109_page0136.PDF','CEN%0761 AC 202109_page0138.PDF','CEN%0761 AC 202109_page0139.PDF','CEN%0761 AC 202109_page0140.PDF','CEN%0761 AC 202109_page0144.PDF','CEN%0761 AC 202109_page0145.PDF','CEN%0761 AC 202109_page0149.PDF','CEN%0761 AC 202109_page0152.PDF','CEN%0761 AC 202109_page0155.PDF','CEN%0761 AC 202109_page0159.PDF','CEN%0761 AC 202109_page0160.PDF','CEN%0761 AC 202109_page0162.PDF','CEN%0761 AC 202109_page0163.PDF','CEN%0761 AC 202109_page0164.PDF','CEN%0761 AC 202109_page0165.PDF','CEN%0761 AC 202109_page0167.PDF','CEN%0761 AC 202109_page0170.PDF','CEN%0761 AC 202109_page0171.PDF','CEN%0761 AC 202109_page0178.PDF','CEN%0761 AC 202109_page0180.PDF','CEN%0761 AC 202109_page0184.PDF','CEN%0761 AC 202109_page0186.PDF','CEN%0761 AC 202109_page0187.PDF','CEN%0761 AC 202109_page0188.PDF','CEN%0761 AC 202109_page0190.PDF','CEN%0761 AC 202109_page0191.PDF','CEN%0761 AC 202109_page0197.PDF','CEN%0761 AC 202109_page0199.PDF','CEN%0761 AC 202109_page0200.PDF','CEN%0761 AC 202109_page0206.PDF','CEN%0761 AC 202109_page0209.PDF','CEN%0761 AC 202109_page0210.PDF','CEN%0761 AC 202109_page0215.PDF','CEN%0761 AC 202109_page0220.PDF','CEN%0761 AC 202109_page0221.PDF','CEN%0761 AC 202109_page0226.PDF','CEN%0761 AC 202109_page0230.PDF','CEN%0761 AC 202109_page0232.PDF','CEN%0761 AC 202109_page0238.PDF','CEN%0761 AC 202109_page0239.PDF','CEN%0761 AC 202109_page0241.PDF','CEN%0761 AC 202109_page0242.PDF','CEN%0761 AC 202109_page0247.PDF','CEN%0761 AC 202109_page0250.PDF','CEN%0761 AC 202109_page0251.PDF','CEN%0761 AC 202109_page0252.PDF','CEN%0761 AC 202109_page0253.PDF','CEN%0761 AC 202109_page0254.PDF','CEN%0761 AC 202109_page0256.PDF','CEN%0761 AC 202109_page0258.PDF','CEN%0761 AC 202109_page0261.PDF','CEN%0761 AC 202109_page0264.PDF','CEN%0761 AC 202109_page0265.PDF','CEN%0761 AC 202109_page0266.PDF','CEN%0761 AC 202109_page0268.PDF','CEN%0761 AC 202109_page0272.PDF','CEN%0761 AC 202109_page0277.PDF','CEN%0761 AC 202109_page0281.PDF','CEN%0761 AC 202109_page0282.PDF','CEN%0761 AC 202109_page0287.PDF','CEN%0761 AC 202109_page0288.PDF','CEN%0761 AC 202109_page0289.PDF','CEN%0761 AC 202109_page0296.PDF','CEN%0761 AC 202109_page0299.PDF','CEN%0761 AC 202109_page0301.PDF','CEN%0761 AC 202109_page0304.PDF','CEN%0761 AC 202109_page0306.PDF','CEN%0761 AC 202109_page0309.PDF','CEN%0761 AC 202109_page0310.PDF','CEN%0761 AC 202109_page0315.PDF','CEN%0761 AC 202109_page0316.PDF','CEN%0761 AC 202109_page0320.PDF','CEN%0761 AC 202109_page0326.PDF','CEN%0761 AC 202109_page0329.PDF','CEN%0761 AC 202109_page0330.PDF','CEN%0761 AC 202109_page0331.PDF','CEN%0761 AC 202109_page0332.PDF','CEN%0761 AC 202109_page0333.PDF','CEN%0761 AC 202109_page0335.PDF','CEN%0761 AC 202109_page0336.PDF','CEN%0761 AC 202109_page0339.PDF','CEN%0761 AC 202109_page0340.PDF','CEN%0761 AC 202109_page0341.PDF','CEN%0761 AC 202109_page0344.PDF','CEN%0761 AC 202109_page0345.PDF','CEN%0761 AC 202109_page0346.PDF','CEN%0761 AC 202109_page0347.PDF','CEN%0761 AC 202109_page0349.PDF','CEN%0761 AC 202109_page0354.PDF','CEN%0761 AC 202109_page0358.PDF','CEN%0761 AC 202109_page0359.PDF','CEN%0761 AC 202109_page0360.PDF','CEN%0761 AC 202109_page0362.PDF','CEN%0761 AC 202109_page0367.PDF','CEN%0761 AC 202109_page0370.PDF','CEN%0761 AC 202109_page0371.PDF','CEN%0761 AC 202109_page0372.PDF','CEN%0761 AC 202109_page0375.PDF','CEN%0761 AC 202109_page0376.PDF','CEN%0761 AC 202109_page0377.PDF','CEN%0761 AC 202109_page0378.PDF','CEN%0761 AC 202109_page0382.PDF','CEN%0761 AC 202109_page0384.PDF','CEN%0761 AC 202109_page0392.PDF','CEN%0761 AC 202109_page0393.PDF','CEN%0761 AC 202109_page0395.PDF','CEN%0761 AC 202109_page0396.PDF','CEN%0761 AC 202109_page0398.PDF','CEN%0761 AC 202109_page0401.PDF','CEN%0761 AC 202109_page0404.PDF','CEN%0761 AC 202109_page0409.PDF','CEN%0761 AC 202109_page0412.PDF','CEN%0761 AC 202109_page0413.PDF','CEN%0761 AC 202109_page0414.PDF','CEN%0761 AC 202109_page0421.PDF','CEN%0761 AC 202109_page0422.PDF','CEN%0761 AC 202109_page0425.PDF','CEN%0761 AC 202109_page0426.PDF','CEN%0761 AC 202109_page0427.PDF','CEN%0761 AC 202109_page0428.PDF','CEN%0761 AC 202109_page0431.PDF','CEN%0761 AC 202109_page0433.PDF','CEN%0761 AC 202109_page0435.PDF','CEN%0761 AC 202109_page0436.PDF','CEN%0761 AC 202109_page0438.PDF','CEN%0761 AC 202109_page0440.PDF','CEN%0761 AC 202109_page0445.PDF','CEN%0761 AC 202109_page0446.PDF','CEN%0761 AC 202109_page0449.PDF','CEN%0761 AC 202109_page0450.PDF','CEN%0761 AC 202109_page0452.PDF','CEN%0761 AC 202109_page0455.PDF','CEN%0761 AC 202109_page0460.PDF','CEN%0761 AC 202109_page0463.PDF','CEN%0761 AC 202109_page0464.PDF','CEN%0761 AC 202109_page0467.PDF','CEN%0761 AC 202109_page0468.PDF','CEN%0761 AC 202109_page0470.PDF','CEN%0761 AC 202109_page0472.PDF','CEN%1380 AC 202108_page0001.PDF','CEN%1380 AC 202108_page0002.PDF','CEN%1380 AC 202108_page0004.PDF','CEN%1380 AC 202108_page0008.PDF','CEN%1380 AC 202108_page0009.PDF','CEN%1380 AC 202108_page0014.PDF','CEN%1380 AC 202108_page0022.PDF','CEN%1380 AC 202108_page0023.PDF','CEN%1380 AC 202108_page0025.PDF','CEN%1380 AC 202108_page0027.PDF','CEN%1380 AC 202108_page0029.PDF','CEN%1380 AC 202108_page0031.PDF','CEN%1380 AC 202108_page0034.PDF','CEN%1380 AC 202108_page0040.PDF','CEN%1380 AC 202108_page0044.PDF','CEN%1380 AC 202108_page0046.PDF','CEN%1380 AC 202108_page0047.PDF','CEN%1380 AC 202108_page0049.PDF','CEN%1380 AC 202108_page0052.PDF','CEN%1380 AC 202108_page0054.PDF','CEN%1380 AC 202108_page0055.PDF','CEN%1380 AC 202108_page0059.PDF','CEN%1380 AC 202109_page0004.PDF','CEN%1380 AC 202109_page0006.PDF','CEN%1380 AC 202109_page0008.PDF','CEN%1380 AC 202109_page0010.PDF','CEN%1380 AC 202109_page0011.PDF','CEN%1380 AC 202109_page0018.PDF','CEN%1380 AC 202109_page0021.PDF','CEN%1380 AC 202109_page0024.PDF','CEN%1380 AC 202109_page0026.PDF','CEN%1380 AC 202109_page0028.PDF','CEN%1380 AC 202109_page0029.PDF','CEN%1380 AC 202109_page0031.PDF','CEN%1380 AC 202109_page0033.PDF','CEN%1380 AC 202109_page0036.PDF','CEN%1380 AC 202109_page0037.PDF','CEN%1380 AC 202109_page0038.PDF','CEN%1380 AC 202109_page0042.PDF','CEN%1380 AC 202109_page0043.PDF','CEN%1380 AC 202109_page0044.PDF','CEN%1380 AC 202109_page0046.PDF','CEN%1380 AC 202109_page0047.PDF','CEN%1380 AC 202109_page0049.PDF','CEN%1380 AC 202109_page0052.PDF','CEN%1380 AC 202109_page0053.PDF','CEN%1380 AC 202109_page0055.PDF','CEN%1380 AC 202109_page0056.PDF','CEN%1380 AC 202109_page0057.PDF','CEN%1380 AC 202109_page0060.PDF','CEN%1380 AC 202109_page0065.PDF','CEN%1380 AC 202109_page0068.PDF','CEN%1380 AC 202109_page0070.PDF','CEN%1380 AC 202109_page0074.PDF','CEN%1380 AC 202109_page0078.PDF','CEN%1380 AC 202109_page0081.PDF','CEN%1380 AC 202109_page0086.PDF','CEN%1380 AC 202109_page0093.PDF','CEN%1380 AC 202109_page0099.PDF','CEN%1380 AC 202109_page0101.PDF','CEN%1380 AC 202109_page0102.PDF','CEN%1380 AC 202109_page0103.PDF','CEN%1380 AC 202109_page0104.PDF','CEN%1380 AC 202109_page0105.PDF','CEN%1380 AC 202109_page0106.PDF','CEN%1380 AC 202109_page0108.PDF','CEN%1380 AC 202109_page0111.PDF','CEN%1380 AC 202109_page0115.PDF','CEN%1380 AC 202109_page0118.PDF','CEN%1380 AC 202109_page0119.PDF','CEN%1380 AC 202109_page0121.PDF','CEN%1380 AC 202109_page0123.PDF','CEN%1380 AC 202109_page0125.PDF','CEN%1380 AC 202109_page0128.PDF','CEN%1380 AC 202109_page0132.PDF','CEN%1380 AC 202109_page0133.PDF','CEN%1380 AC 202109_page0137.PDF','CEN%1380 AC 202109_page0138.PDF','CEN%1380 AC 202109_page0140.PDF','CEN%1380 AC 202109_page0142.PDF','CEN%1380 AC 202109_page0144.PDF','CEN%1380 AC 202109_page0148.PDF','CEN%1380 AC 202109_page0150.PDF','CEN%1380 AC 202109_page0151.PDF','CEN%1380 AC 202109_page0152.PDF','CEN%1380 AC 202109_page0154.PDF','CEN%1380 AC 202109_page0155.PDF','CEN%1380 AC 202109_page0158.PDF','CEN%1380 AC 202109_page0159.PDF','CEN%1380 AC 202109_page0164.PDF','CEN%1380 AC 202109_page0168.PDF','CEN%1380 AC 202109_page0169.PDF','CEN%1380 AC 202109_page0173.PDF','CEN%1380 AC 202109_page0174.PDF','CEN%1380 AC 202109_page0178.PDF','CEN%1380 AC 202109_page0179.PDF','CEN%1380 AC 202109_page0181.PDF','CEN%1380 AC 202109_page0182.PDF','CEN%1380 AC 202109_page0183.PDF','CEN%1380 AC 202109_page0184.PDF','CEN%1380 AC 202109_page0192.PDF','CEN%1380 AC 202109_page0195.PDF','CEN%1380 AC 202109_page0197.PDF','CEN%1380 AC 202109_page0202.PDF','CEN%1380 AC 202109_page0204.PDF','CEN%1380 AC 202109_page0205.PDF','CEN%1380 AC 202109_page0206.PDF','CEN%1380 AC 202109_page0211.PDF','CEN%1380 AC 202109_page0212.PDF','CEN%1380 AC 202109_page0216.PDF','CEN%1380 AC 202109_page0218.PDF','CEN%1380 AC 202109_page0219.PDF','CEN%1380 AC 202109_page0220.PDF','CEN%1380 AC 202109_page0224.PDF','CEN%1380 AC 202109_page0229.PDF','CEN%1380 AC 202109_page0230.PDF','CEN%1380 AC 202109_page0231.PDF','CEN%1380 AC 202109_page0239.PDF','CEN%1380 AC 202109_page0243.PDF','CEN%1380 AC 202109_page0245.PDF','CEN%1380 AC 202109_page0253.PDF','CEN%1380 AC 202109_page0256.PDF','CEN%1380 AC 202109_page0260.PDF','CEN%1380 AC 202109_page0267.PDF','CEN%1380 AC 202109_page0268.PDF','CEN%1380 AC 202109_page0271.PDF','CEN%1380 AC 202109_page0272.PDF','CEN%1380 AC 202109_page0273.PDF','CEN%1380 AC 202109_page0277.PDF','CEN%1380 AC 202109_page0279.PDF','CEN%1380 AC 202109_page0282.PDF','CEN%1380 AC 202109_page0283.PDF','CEN%1380 AC 202109_page0290.PDF','CEN%1380 AC 202109_page0291.PDF','CEN%1380 AC 202109_page0293.PDF','CEN%1380 AC 202109_page0294.PDF','CEN%1380 AC 202109_page0295.PDF','CEN%1380 AC 202109_page0299.PDF','CEN%5732 AC 202109_page0006.PDF','CEN%5732 AC 202109_page0008.PDF','CEN%5732 AC 202109_page0016.PDF','CEN%5732 AC 202109_page0020.PDF','CEN%5732 AC 202109_page0022.PDF','CEN%5732 AC 202109_page0023.PDF','CEN%5732 AC 202109_page0028.PDF','CEN%5732 AC 202109_page0030.PDF','CEN%5732 AC 202109_page0034.PDF','CEN%5732 AC 202109_page0036.PDF','CEN%5732 VE 202109_page0002.PDF','CEN%5732 VE 202109_page0004.PDF','CEN%5732 VE 202109_page0006.PDF','CEN%5861 AC 202109_page0006.PDF','CEN%5861 AC 202109_page0008.PDF','CEN%5861 AC 202109_page0009.PDF','CEN%5861 AC 202109_page0012.PDF','CEN%5861 AC 202109_page0013.PDF','CEN%5861 AC 202109_page0014.PDF','CEN%5861 AC 202109_page0015.PDF','CEN%5861 AC 202109_page0016.PDF','CEN%5861 AC 202109_page0017.PDF','CEN%5861 AC 202109_page0020.PDF','CEN%5861 AC 202109_page0024.PDF','CEN%5861 AC 202109_page0025.PDF','CEN%5861 AC 202109_page0027.PDF','CEN%5861 AC 202109_page0031.PDF','CEN%5861 AC 202109_page0039.PDF','CEN%5861 AC 202109_page0040.PDF','CEN%5861 AC 202109_page0049.PDF','CEN%5861 AC 202109_page0056.PDF','CEN%5861 AC 202109_page0060.PDF','CEN%5861 AC 202109_page0063.PDF','CEN%5861 AC 202109_page0065.PDF','CEN%5861 AC 202109_page0067.PDF','CEN%5861 AC 202109_page0068.PDF','CEN%5861 AC 202109_page0073.PDF','CEN%5861 AC 202109_page0079.PDF','CEN%5861 AC 202109_page0081.PDF','CEN%5861 AC 202109_page0085.PDF','CEN%5861 AC 202109_page0089.PDF','CEN%5861 AC 202109_page0090.PDF','CEN%5861 AC 202109_page0091.PDF','CEN%5861 AC 202109_page0092.PDF','CEN%5861 AC 202109_page0098.PDF','CEN%5861 AC 202109_page0100.PDF','CEN%5861 AC 202109_page0102.PDF','CEN%5861 AC 202109_page0107.PDF','CEN%5861 AC 202109_page0109.PDF','CEN%5861 AC 202109_page0110.PDF','CEN%5861 AC 202109_page0111.PDF','CEN%5861 AC 202109_page0112.PDF','CEN%5861 AC 202109_page0116.PDF','CEN%5861 AC 202109_page0119.PDF','CEN%5861 AC 202109_page0120.PDF','CEN%5861 AC 202109_page0121.PDF','CEN%5861 AC 202109_page0122.PDF','CEN%5861 AC 202109_page0124.PDF','CEN%5861 AC 202109_page0125.PDF','CEN%5861 AC 202109_page0126.PDF','CEN%5861 AC 202109_page0131.PDF','CEN%5861 AC 202109_page0134.PDF','CEN%5861 AC 202109_page0136.PDF','CEN%5861 AC 202109_page0148.PDF','CEN%5861 AC 202109_page0149.PDF','CEN%5861 AC 202109_page0150.PDF','CEN%5861 AC 202109_page0153.PDF','CEN%5861 AC 202109_page0161.PDF','CEN%5861 AC 202109_page0167.PDF','CEN%5861 AC 202109_page0170.PDF','CEN%5861 AC 202109_page0171.PDF','CEN%5861 AC 202109_page0176.PDF','CEN%5861 AC 202109_page0179.PDF','CEN%5861 AC 202109_page0180.PDF','CEN%5861 AC 202109_page0181.PDF','CEN%5861 AC 202109_page0182.PDF','CEN%5861 AC 202109_page0186.PDF','CEN%5861 AC 202109_page0187.PDF','CEN%5861 AC 202109_page0188.PDF','CEN%5861 AC 202109_page0192.PDF','CEN%5861 AC 202109_page0193.PDF','CEN%5861 AC 202109_page0194.PDF','CEN%5861 AC 202109_page0196.PDF','CEN%5861 AC 202109_page0197.PDF','CEN%6307 AC 202107_page0001.PDF','CEN%6307 AC 202107_page0002.PDF','CEN%6307 AC 202107_page0005.PDF','CEN%6307 AC 202107_page0007.PDF','CEN%6307 AC 202107_page0008.PDF','CEN%6307 AC 202107_page0011.PDF','CEN%6307 AC 202107_page0015.PDF','CEN%6307 AC 202107_page0016.PDF','CEN%6307 AC 202107_page0021.PDF','CEN%6307 AC 202107_page0023.PDF','CEN%6307 AC 202107_page0033.PDF','CEN%6307 VE 202107_page0003.PDF','CEN%6307 VE 202107_page0006.PDF','CEN%6307 VE 202107_page0008.PDF','CEN%6307 VE 202107_page0011.PDF','CEN%6307 VE 202107_page0013.PDF','CEN%6307 VE 202107_page0014.PDF','CEN%6307 VE 202107_page0017.PDF','CEN%6307 VE 202107_page0018.PDF','CEN%6307 VE 202107_page0019.PDF','CEN%6307 VE 202107_page0021.PDF','CEN%6307 VE 202107_page0023.PDF','CEN%6307 VE 202107_page0025.PDF','CEN%6307 VE 202107_page0028.PDF','CEN%6307 VE 202107_page0030.PDF','CEN%6307 VE 202107_page0032.PDF','CEN%6307 VE 202107_page0034.PDF','CEN%6307 VE 202107_page0035.PDF','CEN%6307 VE 202109_page0001.PDF','CEN%6307 VE 202109_page0003.PDF','CEN%6307 VE 202109_page0005.PDF','CEN%6307 VE 202109_page0007.PDF','CEN%6307 VE 202109_page0009.PDF','CEN%6307 VE 202109_page0014.PDF','CEN%6307 VE 202109_page0015.PDF','CEN%6307 VE 202109_page0017.PDF','CEN%6307 VE 202109_page0018.PDF','CEN%6307 VE 202109_page0022.PDF','CEN%6307 VE 202109_page0028.PDF','CEN%6307 VE 202109_page0031.PDF','CEN%6307 VE 202109_page0032.PDF','CEN%6307 VE 202109_page0034.PDF','CEN%6307 VE 202109_page0040.PDF','CEN%6352 AC 202109_page0006.PDF','CEN%6352 AC 202109_page0011.PDF','CEN%6352 AC 202109_page0012.PDF','CEN%6352 AC 202109_page0017.PDF','CEN%6352 VE 202109_page0001.PDF','CEN%6352 VE 202109_page0003.PDF','CEN%6352 VE 202109_page0010.PDF','CEN%6352 VE 202109_page0014.PDF','CEN%6352 VE 202109_page0017.PDF','CEN%M057 AC 202110_page0005.PDF','CEN%M057 AC 202110_page0006.PDF','CEN%M057 AC 202110_page0008.PDF','CEN%M057 AC 202110_page0010.PDF','CEN%M057 AC 202110_page0011.PDF','CEN%M057 AC 202110_page0014.PDF','CEN%M057 AC 202110_page0018.PDF','CEN%M057 AC 202110_page0021.PDF','CEN%M057 AC 202110_page0022.PDF','CEN%M057 AC 202110_page0024.PDF','CEN%M057 AC 202110_page0031.PDF','CEN%M057 AC 202110_page0033.PDF','CEN%M057 AC 202110_page0035.PDF','CEN%M057 AC 202110_page0037.PDF','CEN%M057 AC 202110_page0041.PDF','CEN%M057 AC 202110_page0042.PDF','CEN%M057 AC 202110_page0044.PDF','CEN%M057 AC 202110_page0045.PDF','CEN%M057 AC 202110_page0048.PDF','CEN%M057 AC 202110_page0049.PDF','CEN%M057 AC 202110_page0050.PDF','CEN%M057 AC 202110_page0052.PDF','CEN%M057 AC 202110_page0053.PDF','CEN%M150 AC 202110_page0004.PDF','CEN%M150 AC 202110_page0008.PDF','CEN%M150 AC 202110_page0010.PDF','CEN%M150 AC 202110_page0013.PDF','CEN%M150 AC 202110_page0016.PDF','CEN%M150 AC 202110_page0019.PDF','CEN%M150 AC 202110_page0021.PDF','CEN%M150 AC 202110_page0025.PDF','CEN%M150 AC 202110_page0026.PDF','CEN%M150 AC 202110_page0027.PDF','CEN%M150 AC 202110_page0029.PDF','CEN%M150 AC 202110_page0032.PDF','CEN%M150 AC 202110_page0034.PDF','CEN%M150 AC 202110_page0035.PDF','CEN%M150 AC 202110_page0040.PDF','CEN%M150 AC 202110_page0042.PDF','CEN%N077 AC 202110_page0006.PDF','CEN%N077 AC 202110_page0010.PDF','CEN%N077 AC 202110_page0012.PDF','CEN%N077 AC 202110_page0014.PDF','CEN%N077 AC 202110_page0015.PDF','CEN%N077 AC 202110_page0016.PDF','CEN%N077 AC 202110_page0017.PDF','CEN%N077 AC 202110_page0020.PDF','CEN%N077 AC 202110_page0026.PDF','CEN%N077 AC 202110_page0027.PDF','CEN%N077 AC 202110_page0031.PDF','CEN%N077 AC 202110_page0035.PDF','CEN%N077 AC 202110_page0038.PDF']

    begin
      ftp = Net::FTP.new
      ftp.connect url, 21
      ftp.login username, password
      ftp.passive = true

      Ftp::Fetcher::Processor.new(ftp, dir).execute

      ftp.chdir dir

      dirs = ftp.nlst.sort

      if (uncomplete_deliveries = check_uncomplete_delivery(ftp, dirs)).any?
        Notifications::ScanService.new({deliveries: uncomplete_deliveries}).notify_uncompleted_delivery
        ftp.chdir dir
        uncomplete_deliveries.each { |file_path| ftp.delete("#{file_path}.uncomplete") rescue false }
      end

      ready_dirs(dirs).each do |dir|
        p "==== Traiement de : #{dir} ======"
        ftp.chdir dir
        date      = dir[0..9]
        position = dir[11..-7] || 1

        corrupted_documents = []

        document_delivery = DocumentDelivery.find_or_create_by(date, provider, position)

        p "========== Scan en cours =============="

        file_names = valid_file_names(ftp.nlst.sort)
        counts     = file_names.try(:size).to_i

        p "=========== Total: #{counts} ============"

        grouped_packs(file_names).each do |pack_name, file_names|
          documents = []
          p "=========== Pack: #{pack_name} ============"

          if not include_pack.include?(pack_name.gsub('_', ' ').strip)
            p "========== Saut Pack: #{pack_name}============="
            next
          end

          file_names.each_with_index do |file_name, index|
            counts = counts - 1
            p "=========== Traitement: #{file_name} : #{counts} / #{file_names.size} ============"

            if exclude_files.include?(file_name)
              p "=======Saut fichier: #{file_name}======"
              next
            end

            document = document_delivery.temp_documents.where(original_file_name: file_name).first

            if !document || (document && document.unreadable?)
              get_file ftp, file_name, clean_file_name(file_name) do |file|
                pack_name = CustomUtils.replace_code_of(pack_name)

                document = document_delivery.add_or_replace(file, original_file_name: file_name,
                                                                  delivery_type: 'scan',
                                                                  api_name: 'scan',
                                                                  delivered_by: provider,
                                                                  pack_name: pack_name)
              end
            end

            documents << document
            corrupted_documents << document if document.unreadable? && !document.is_corruption_notified

            
            sleep(5) if (index % 15) == 0
          end

          if documents.select(&:unreadable?).count == 0 && documents.select(&:is_locked).count > 0
            document_ids = documents.map(&:id)
            TempDocument.where(id: document_ids).update_all(is_locked: false)
          end

          sleep(3)
        end

        ftp.chdir '..'

        # if document_delivery.valid_documents?
        if counts <= 0
          document_delivery.processed

          ftp.rename dir, fetched_dir(dir)

          document_delivery.temp_documents.group_by(&:user).each do |user, temp_documents|
            Notifications::Documents.new({user: user, new_count: temp_documents.count}).notify_new_scaned_documents
          end
        end

        # notify corrupted documents
        next unless corrupted_documents.count > 0

        subject = '[iDocus] Documents corrompus'
        content = "Livraison : #{dir}\n"
        content = "Total : #{corrupted_documents.count}\n"
        content << "Fichier(s) : #{corrupted_documents.map(&:original_file_name).join(', ')}"

        addresses = Array(Settings.first.notify_errors_to)

        unless addresses.empty?
          NotificationMailer.notify(addresses, subject, content)
        end

        corrupted_documents.each(&:corruption_notified)
      end

      ftp.close
    rescue Errno::ETIMEDOUT, EOFError => e
      System::Log.info('debug_ftp', "[#{Time.now}] FTP: connect to #{url} : #{e.to_s}")
      false
    rescue Net::FTPConnectionError, Net::FTPError, Net::FTPPermError, Net::FTPProtoError, Net::FTPReplyError, Net::FTPTempError, SocketError, Errno::ECONNREFUSED => e
      content = "#{e.class}<br /><br />#{e.message}"
      addresses = Array(Settings.first.notify_errors_to)

      unless addresses.empty?
        NotificationMailer.notify(addresses, "[iDocus] Erreur lors de la récupération des documents ppp", content).deliver_later
      end

      false
    end
  end


  def self.ready_dirs(dirs)
    dirs.select do |e|
      e.end_with?('ready')
    end
  end

  def self.check_uncomplete_delivery(ftp, dirs)
    dirs.select { |file_path| file_path.end_with?('uncomplete') && ftp.mtime(file_path).localtime < 30.minutes.ago }.inject([]) do |uncomplete_deliveries, file_path|
      expected_quantity  = ftp.gettextfile(file_path, nil).chop.to_i
      dir = File.basename(file_path, ".*")
      ftp.chdir dir
      if expected_quantity == ftp.nlst.size
        ftp.chdir '..'
        ftp.rename file_path, "#{dir}.uploaded"
      else
        uncomplete_deliveries << dir
      end
      uncomplete_deliveries
    end
  end

  def self.grouped_packs(file_names)
    file_names.group_by do |e|
      result = e.scan(/\A(#{Pack::CODE_PATTERN}(_| )#{Pack::JOURNAL_PATTERN}(_| )#{Pack::PERIOD_PATTERN})/)[0][0]

      result.tr(' ', '_')
    end
  end


  def self.fetched_dir(dir)
    dir.sub('ready', 'fetched')
  end


  def self.clean_file_name(file_name)
    file_name.gsub(/\s/, '_').sub(/.PDF\z/, '.pdf').gsub(/page(\d+)(\.pdf)\z/i, '\1\2')
  end


  def self.valid_file_names(file_names)
    file_names.select do |e|
      e.match FILENAME_PATTERN
    end
  end


  def self.get_file(ftp, file_name, new_file_name)
    CustomUtils.mktmpdir('ftp_fetcher') do |dir|
      begin
        file = File.open(File.join(dir, new_file_name), 'w')
        ftp.getbinaryfile(file_name, file.path)

        yield(file)
      ensure
        file.close
      end
    end
  end

  class Processor
    def initialize(ftp, root)
      @root_path = "/nfs/ppp/"
      @ftp = ftp

      @ftp.chdir root

      @code_pattern = '[a-zA-Z0-9]+[%#]*[a-zA-Z0-9]*'
      @journal_pattern = '[a-zA-Z0-9]+'
      @period_pattern = '\d{4}([01T]\d)*'
    end

    def execute
      CustomUtils.add_chmod_access_into("/nfs/ppp/")

      dirs = @ftp.nlst.sort

      dirs.each do |f_path|
        file_path = @root_path + f_path

        if file_path && file_path.match(/\.uploaded$/)
          dir = File.basename file_path, '.*'
          dir = @root_path + dir

          log_document = {
            subject: "[FtpFetcher] - scanned uploaded file",
            name: "ftp fetcher",
            error_group: "[FtpFetcher] scanned uploaded file",
            erreur_type: "[FtpFetcher] - scanned uploaded file",
            date_erreur: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
            more_information: {
              file_path: file_path,
              dir: dir.to_s,
              dir_exist: File.exist?(dir)
            }
          }

          begin
            ErrorScriptMailer.error_notification(log_document, { attachements: [{ name: File.basename(file_path), file: File.open(file_path) }] }).deliver
          rescue
            ErrorScriptMailer.error_notification(log_document).deliver
          end

          if File.exist?(dir)
            if Dir.glob(dir + '/*').size == File.read(file_path).to_i
              File.rename dir, "#{dir}_processing"

              process("#{dir}_processing")

              File.delete file_path
              File.rename "#{dir}_processing", "#{dir}_ready"
            else
              File.rename file_path, "#{dir}.uncomplete"
            end
          end
        end
      end
    end

    def valid?(file_path)
      begin
        [1,2].include?(DocumentTools.pages_number(file_path))
      rescue GLib::Error
        false
      end
    end

    def process(path)
      file_paths = Dir.glob(path + '/*').sort

      grouped_packs(file_paths).each do |pack_name, file_names|
        invalid_files = []

        file_names.each do |file_path|
          unless valid?(file_path)
            invalid_files << file_path 
          end
        end

        if invalid_files.any?
          dir = path.gsub('_processing', '_errors')
          FileUtils.makedirs(dir)
          FileUtils.chmod(0755, dir)

          move_to_error(dir, file_names, invalid_files)
        end
      end
    end

    def grouped_packs(file_names)
      file_names.group_by do |e|
        result = File.basename(e).scan(/\A(#{@code_pattern}(_| )#{@journal_pattern}(_| )#{@period_pattern})/)[0][0]
      end
    end

    def move_to_error(dir, file_names, invalid_files)
      file_names.each do |file_path|
        error_file_name = invalid_files.include?(file_path) ? File.basename(file_path, '.*') + '_error' + File.extname(file_path) : File.basename(file_path)
        FileUtils.mv file_path, "#{dir}/#{error_file_name}"
      end
    end
  end
end