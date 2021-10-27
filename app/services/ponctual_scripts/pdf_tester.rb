class PonctualScripts::PdfTester < PonctualScripts::PonctualScript
  def self.execute
    new().run
  end

  private

  def execute
    Prawn::Document.generate "#{Rails.root}/tmp/#{Time.now.strftime("Y%m%d%H%M%s")}_test.pdf" do |pdf|
      @pdf = pdf      

      @pdf.font 'Helvetica'
      @pdf.fill_color '49442A'

      @pdf.font_size 8
      @pdf.default_leading 4

      # @pdf.text_box "DOIT",  at: [250, 1]
      @pdf.image "#{Rails.root}/app/assets/images/logo/small_logo.png", width: 85, height: 40, style: :bold   

      @pdf.text_box 'DOIT:', at: [275, 725], height: 100, width: 100, style: :bold
      
      header_et = 
        [
          "REFERENCE ETUV:",
          "QUINCAILLERIE/MAGASIN ETUV:",
          "LIEU DE VENTE:",
          "NUMERO NIF:",
          "NUMERO STAT:"
        ].join("\n")

      @pdf.bounding_box([300, 725 ], width: 240) do
        @pdf.text header_et, align: :left, style: :bold

      end

      header_et = 
        [
          "Q010",
          "HARENA",
          "AMBOHIMAMORY",
          "2000000026070",
          "754585421545"
        ].join("\n")

      @pdf.bounding_box([440, 725], width: 140) do        
        @pdf.text header_et, align: :left, style: :bold    

      end

      header_et = 
        [
          "LOT AV643 TER LOHARANOMBATO",
          "Tél : 034 71 482 13 - 032 85 871 20",
          "NIF N°",
          "STAT N°"
        ].join("\n")
            
      @pdf.bounding_box([0, @pdf.cursor], width: 240) do
        @pdf.text header_et, align: :left, style: :bold

      end

      @pdf.move_down 10

      header_et = 
        [
          "FACTURE N° :",
          "Date:"
        ].join("\n")

      cursor = @pdf.cursor

      @pdf.bounding_box([0, @pdf.cursor], width: 240) do
        @pdf.text header_et, align: :left, style: :bold

      end

      header_et = 
        [
          "001-05-10",
          "05/10/2021"
        ].join("\n")

      @pdf.bounding_box([100, cursor], width: 240) do
        @pdf.text header_et, align: :left, style: :bold

      end
      @pdf.move_down 10

      data = [['<b>DESIGNATION</b>', '<b>QTTE (Carton)</b>', '<b>P.U Htaxes<[Ar]</b>', '<b>P.T Htaxes [Ar]</b>', '<b>Remise Accordée</b>', '<b>Total Htaxes [Ar]</b>']]     
      data += [['CALE BETON 20/30', '10', '29 167', '291 167', '2%', '282 333']]     
      data += [['CALE BETON 25/35', '10', '29 167', '291 167', '2%', '285 333']] 
      # data += [['', '', '', '', '<b>Montant Htaxes [Ar] =</b>', '568 750']]
      # data += [['', '', '', '', '<b>TVA 20% [Ar] =</b>', '113 750']]
      # data += [['', '', '', '', '<b>Montant TTC [Ar] =</b>', '682 500']]

      @pdf.table(data, width: 540, cell_style: { inline_format: true }) do
        style(row(0..-1), borders: [:left, :right, :top, :bottom], text_color: '49442A')
        style(row(0), borders: [:left, :right, :top, :bottom])
        style(row(-1), borders: [:left, :right, :top, :bottom])
      end

      @pdf.move_down 7
      @pdf.float do
        @pdf.text_box 'Montant Htaxes [Ar] =', at: [340, @pdf.cursor], width: 100, align: :right, style: :bold
      end

      @pdf.text_box "568 750", at: [460, @pdf.cursor], width: 66, align: :center
      @pdf.move_down 12
      @pdf.stroke_horizontal_line 355, 540, at: @pdf.cursor

      @pdf.move_down 7
      @pdf.float do
        @pdf.text_box 'TVA 20% [Ar] =', at: [340, @pdf.cursor], width: 100, align: :right, style: :bold
      end

      @pdf.text_box "568 750", at: [460, @pdf.cursor], width: 66, align: :center
      @pdf.move_down 12
      @pdf.stroke_horizontal_line 355, 540, at: @pdf.cursor

      @pdf.move_down 7
      @pdf.float do
        @pdf.text_box 'Montant TTC [Ar] =', at: [340, @pdf.cursor], width: 100, align: :right, style: :bold
      end

      @pdf.text_box "568 750", at: [460, @pdf.cursor], width: 66, align: :center
      @pdf.move_down 12
      @pdf.stroke_horizontal_line 355, 540, at: @pdf.cursor

      @pdf.move_down 10
      cursor = @pdf.cursor

      header_et = 
        [
          "Arreté à la somme de :",
          "MODE DE PAIEMENT :",
          "DATE DE LIVRAISON :"
        ].join("\n")

      @pdf.bounding_box([10, cursor], width: 240) do
        @pdf.text header_et, align: :left, style: :bold

      end

      header_et = 
        [
          "Six cent quatre vingt",
          "ESPECE",
          "06/10/2021"
        ].join("\n")

      @pdf.bounding_box([100, cursor], width: 240) do
        @pdf.text header_et, align: :left, style: :bold

      end

      @pdf.text_box 'SIGNATURE CLIENT:', at: [300, cursor], height: 100, width: 100, :styles => [:underline]

      @pdf
    end
  end
end
