class FillAccountBookTypeRelationValues
  def self.execute()
    AccountBookType.all.each_with_index do |journal|
      #Pack
      packs = Pack.where("name LIKE '% #{journal.try(:name)} %'")

      packs.each_with_index do |pack, index|
        pack.account_book_type_id = journal.id
        pack.save

        sleep(5) if index % 100

        #operation
        pack.operations.each do |operation, index|
          operation.account_book_type_id = journal.id
          operation.save

          sleep(5) if index % 100
        end

      end

      #TempPack
      temp_packs = TempPack.where("name LIKE '% #{journal.try(:name)} %'")

      temp_packs.each_with_index do |temp_pack, index|
        temp_pack.account_book_type_id = journal.id
        temp_pack.save

        sleep(5) if index % 100

        #tempdocument
        temp_pack.temp_documents.each do |temp_document, index|
          temp_document.account_book_type_id = journal.id
          temp_document.save

          sleep(5) if index % 100
        end
      end

      #Piece
      pieces = Pack::Piece.where("name LIKE '% #{journal.try(:name)} %'")

      pieces.each_with_index do |piece, index|
        piece.account_book_type_id = journal.id
        piece.save

        sleep(5) if index % 100
      end


      #Report
      reports = Pack::Report.where("name LIKE '% #{journal.try(:name)} %'")

      reports.each_with_index do |report, index|
        report.account_book_type_id = journal.id
        report.save

        sleep(5) if index % 100

        #preseizure
        report.preseizures.each do |preseizure, index|
          preseizure.account_book_type_id = journal.id
          preseizure.save

          sleep(5) if index % 100
        end
      end

    end
  end
end
