class RemoveAlphaBetaColumnsToEncrypted < ActiveRecord::Migration[5.2]
	
	def change
		#1. archive_budgea_users "Archive::BudgeaUser"
		remove_column :archive_budgea_users, :alpha_access_token, :text
		remove_column :archive_budgea_users, :beta_access_token, :text

		#2. boxes "Box"
		remove_column :boxes, :alpha_access_token, :string
		remove_column :boxes, :beta_access_token, :string
		remove_column :boxes, :alpha_refresh_token, :string
		remove_column :boxes, :beta_refresh_token, :string

		#3. bridge_accounts "BridgeAccount"
		remove_column :bridge_accounts, :alpha_username, :string
		remove_column :bridge_accounts, :beta_username, :string
		remove_column :bridge_accounts, :alpha_password, :string
		remove_column :bridge_accounts, :beta_password, :string

		#4. budgea_accounts "BudgeaAccount"
		remove_column :budgea_accounts, :alpha_access_token, :text
		remove_column :budgea_accounts, :beta_access_token, :text

		#5. dropbox_basics "DropboxBasic"
		remove_column :dropbox_basics, :alpha_access_token, :string
		remove_column :dropbox_basics, :beta_access_token, :string

		#6. exact_online "ExactOnline"
		remove_column :exact_online, :alpha_client_id, :text 
		remove_column :exact_online, :beta_client_id, :text 
		remove_column :exact_online, :alpha_client_secret,   :text 
		remove_column :exact_online, :beta_client_secret, :text 
		remove_column :exact_online, :alpha_refresh_token,   :text 
		remove_column :exact_online, :beta_refresh_token, :text 
		remove_column :exact_online, :alpha_access_token,   :text 
		remove_column :exact_online, :beta_access_token, :text 

		#7. ftps "Ftp"
		remove_column :ftps, :alpha_host, :string
		remove_column :ftps, :beta_host, :string
		remove_column :ftps, :alpha_login, :string
		remove_column :ftps, :beta_login, :string
		remove_column :ftps, :alpha_password, :string
		remove_column :ftps, :beta_password, :string
		remove_column :ftps, :alpha_port, :string
		remove_column :ftps, :beta_port, :string

		#8. google_docs "GoogleDoc"
		remove_column :google_docs, :alpha_access_token, :text
		remove_column :google_docs, :beta_access_token, :text
		remove_column :google_docs, :alpha_refresh_token, :text
		remove_column :google_docs, :beta_refresh_token, :text
		remove_column :google_docs, :alpha_access_token_expires_at, :text
		remove_column :google_docs, :beta_access_token_expires_at, :text

		#9. ibizas "Ibiza"
		remove_column :ibizas, :alpha_access_token, :text
		remove_column :ibizas, :beta_access_token, :text
		remove_column :ibizas, :alpha_access_token_2, :text
		remove_column :ibizas, :beta_access_token_2, :text

		#10. ibizas_old
		#remove_column :ibizas_old, :alpha_access_token, :text
		#remove_column :ibizas_old, :beta_access_token, :text
		#remove_column :ibizas_old, :alpha_access_token_2, :text
		#remove_column :ibizas_old, :beta_access_token_2, :text

		#10. knowings "Knowings"
		remove_column :knowings, :alpha_url, :string
		remove_column :knowings, :beta_url, :string
		remove_column :knowings, :alpha_username, :string
		remove_column :knowings, :beta_username, :string
		remove_column :knowings, :alpha_password, :string
		remove_column :knowings, :beta_password, :string

		#11. mcf_settings "McfSettings"
		remove_column :mcf_settings, :alpha_access_token, :string
		remove_column :mcf_settings, :beta_access_token, :string
		remove_column :mcf_settings, :alpha_refresh_token, :string
		remove_column :mcf_settings, :beta_refresh_token, :string
		remove_column :mcf_settings, :alpha_access_token_expires_at, :string
		remove_column :mcf_settings, :beta_access_token_expires_at, :string

		#12. new_provider_requests "NewProviderRequest"
		remove_column :new_provider_requests, :alpha_url, :text
		remove_column :new_provider_requests, :beta_url, :text
		remove_column :new_provider_requests, :alpha_login, :string
		remove_column :new_provider_requests, :beta_login, :string
		remove_column :new_provider_requests, :alpha_description, :text
		remove_column :new_provider_requests, :beta_description, :text
		remove_column :new_provider_requests, :alpha_message, :text
		remove_column :new_provider_requests, :beta_message, :text
		remove_column :new_provider_requests, :alpha_email, :string
		remove_column :new_provider_requests, :beta_email, :string
		remove_column :new_provider_requests, :alpha_types, :string
		remove_column :new_provider_requests, :beta_types, :string

		#13. organizations "Organization"
		remove_column :organizations, :alpha_cedricom_password, :string
		remove_column :organizations, :beta_cedricom_password, :string
		remove_column :organizations, :alpha_jedeclare_password, :string
		remove_column :organizations, :beta_jedeclare_password, :string

		#14. retrievers "Retriever"
		remove_column :retrievers, :alpha_login, :string
		remove_column :retrievers, :beta_login, :string
		remove_column :retrievers, :alpha_password, :string
		remove_column :retrievers, :beta_password, :string

		#5. sftps "Sftp"
		remove_column :sftps, :alpha_host, :string
		remove_column :sftps, :beta_host, :string
		remove_column :sftps, :alpha_login, :string
		remove_column :sftps, :beta_login, :string
		remove_column :sftps, :alpha_password, :string
		remove_column :sftps, :beta_password, :string		
		remove_column :sftps, :alpha_port, :string
		remove_column :sftps, :beta_port, :string

		#16. software_acds "Software::Acd"
		remove_column :software_acds, :alpha_password, :string
		remove_column :software_acds, :beta_password, :string

		#17. software_exact_online "Software::ExactOnline"
		remove_column :software_exact_online, :alpha_client_id, :text
		remove_column :software_exact_online, :beta_client_id, :text
		remove_column :software_exact_online, :alpha_client_secret, :text
		remove_column :software_exact_online, :beta_client_secret, :text
		remove_column :software_exact_online, :alpha_access_token, :text
		remove_column :software_exact_online, :beta_access_token, :text
		remove_column :software_exact_online, :alpha_refresh_token, :text
		remove_column :software_exact_online, :beta_refresh_token, :text

		#18. software_ibizas "Software::Ibiza"
		remove_column :software_ibizas, :alpha_access_token, :text
		remove_column :software_ibizas, :beta_access_token, :text
		remove_column :software_ibizas, :alpha_access_token_2, :text
		remove_column :software_ibizas, :beta_access_token_2, :text

		#19. software_my_unisofts "Software::MyUnisoft"
		remove_column :software_my_unisofts, :alpha_api_token, :text
		remove_column :software_my_unisofts, :beta_api_token, :text

		#20. users "User"
		remove_column :users, :alpha_password, :string
		remove_column :users, :beta_password, :string
	end
end
