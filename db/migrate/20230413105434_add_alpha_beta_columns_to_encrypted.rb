class AddAlphaBetaColumnsToEncrypted < ActiveRecord::Migration[5.2]
	def change
		#1. archive_budgea_users "Archive::BudgeaUser"
		add_column :archive_budgea_users, :access_token, :text
		add_column :archive_budgea_users, :alpha_access_token, :text
		add_column :archive_budgea_users, :beta_access_token, :text

		#2. boxes "Box"
		add_column :boxes, :access_token, :string
		add_column :boxes, :alpha_access_token, :string
		add_column :boxes, :beta_access_token, :string
		add_column :boxes, :refresh_token, :string
		add_column :boxes, :alpha_refresh_token, :string
		add_column :boxes, :beta_refresh_token, :string

		#3. bridge_accounts "BridgeAccount"
		add_column :bridge_accounts, :username, :string
		add_column :bridge_accounts, :alpha_username, :string
		add_column :bridge_accounts, :beta_username, :string
		add_column :bridge_accounts, :password, :string
		add_column :bridge_accounts, :alpha_password, :string
		add_column :bridge_accounts, :beta_password, :string

		#4. budgea_accounts "BudgeaAccount"
		add_column :budgea_accounts, :access_token, :text
		add_column :budgea_accounts, :alpha_access_token, :text
		add_column :budgea_accounts, :beta_access_token, :text

		#5. dropbox_basics "DropboxBasic"
		add_column :dropbox_basics, :access_token, :string
		add_column :dropbox_basics, :alpha_access_token, :string
		add_column :dropbox_basics, :beta_access_token, :string

		#6. exact_online "ExactOnline"
		add_column :exact_online, :client_id, :text
		add_column :exact_online, :alpha_client_id, :text
		add_column :exact_online, :beta_client_id, :text
		add_column :exact_online, :client_secret, :text
		add_column :exact_online, :alpha_client_secret, :text
		add_column :exact_online, :beta_client_secret, :text
		add_column :exact_online, :refresh_token, :text
		add_column :exact_online, :alpha_refresh_token, :text
		add_column :exact_online, :beta_refresh_token, :text
		add_column :exact_online, :access_token, :text
		add_column :exact_online, :alpha_access_token,   :text
		add_column :exact_online, :beta_access_token, :text

		#7. ftps "Ftp"
		add_column :ftps, :host, :string
		add_column :ftps, :alpha_host, :string
		add_column :ftps, :beta_host, :string
		add_column :ftps, :login, :string
		add_column :ftps, :alpha_login, :string
		add_column :ftps, :beta_login, :string
		add_column :ftps, :password, :string
		add_column :ftps, :alpha_password, :string
		add_column :ftps, :beta_password, :string
		add_column :ftps, :port, :string
		add_column :ftps, :alpha_port, :string
		add_column :ftps, :beta_port, :string

		#8. google_docs "GoogleDoc"
		add_column :google_docs, :access_token, :text
		add_column :google_docs, :alpha_access_token, :text
		add_column :google_docs, :beta_access_token, :text
		add_column :google_docs, :refresh_token, :text
		add_column :google_docs, :alpha_refresh_token, :text
		add_column :google_docs, :beta_refresh_token, :text
		add_column :google_docs, :access_token_expires_at, :text
		add_column :google_docs, :alpha_access_token_expires_at, :text
		add_column :google_docs, :beta_access_token_expires_at, :text

		#9. ibizas "Ibiza"
		add_column :ibizas, :access_token, :text
		add_column :ibizas, :alpha_access_token, :text
		add_column :ibizas, :beta_access_token, :text
		add_column :ibizas, :access_token_2, :text
		add_column :ibizas, :alpha_access_token_2, :text
		add_column :ibizas, :beta_access_token_2, :text

		#10. ibizas_old
		#add_column :ibizas_old, :access_token, :text
		#add_column :ibizas_old, :alpha_access_token, :text
		#add_column :ibizas_old, :beta_access_token, :text
		#add_column :ibizas_old, :access_token_2, :text
		#add_column :ibizas_old, :alpha_access_token_2, :text
		#add_column :ibizas_old, :beta_access_token_2, :text

		#10. knowings "Knowings"
		add_column :knowings, :url, :string
		add_column :knowings, :alpha_url, :string
		add_column :knowings, :beta_url, :string
		add_column :knowings, :username, :string
		add_column :knowings, :alpha_username, :string
		add_column :knowings, :beta_username, :string
		add_column :knowings, :password, :string
		add_column :knowings, :alpha_password, :string
		add_column :knowings, :beta_password, :string

		#11. mcf_settings "McfSettings"
		add_column :mcf_settings, :access_token, :string
		add_column :mcf_settings, :alpha_access_token, :string
		add_column :mcf_settings, :beta_access_token, :string
		add_column :mcf_settings, :refresh_token, :string
		add_column :mcf_settings, :alpha_refresh_token, :string
		add_column :mcf_settings, :beta_refresh_token, :string
		add_column :mcf_settings, :access_token_expires_at, :string
		add_column :mcf_settings, :alpha_access_token_expires_at, :string
		add_column :mcf_settings, :beta_access_token_expires_at, :string

		#12. new_provider_requests "NewProviderRequest"
		add_column :new_provider_requests, :url, :text
		add_column :new_provider_requests, :alpha_url, :text
		add_column :new_provider_requests, :beta_url, :text
		add_column :new_provider_requests, :login, :string
		add_column :new_provider_requests, :alpha_login, :string
		add_column :new_provider_requests, :beta_login, :string
		add_column :new_provider_requests, :description, :text
		add_column :new_provider_requests, :alpha_description, :text
		add_column :new_provider_requests, :beta_description, :text
		add_column :new_provider_requests, :message, :text
		add_column :new_provider_requests, :alpha_message, :text
		add_column :new_provider_requests, :beta_message, :text
		add_column :new_provider_requests, :email, :string
		add_column :new_provider_requests, :alpha_email, :string
		add_column :new_provider_requests, :beta_email, :string
		add_column :new_provider_requests, :types, :string
		add_column :new_provider_requests, :alpha_types, :string
		add_column :new_provider_requests, :beta_types, :string

		#13. organizations "Organization"
		add_column :organizations, :cedricom_password, :string
		add_column :organizations, :alpha_cedricom_password, :string
		add_column :organizations, :beta_cedricom_password, :string
		add_column :organizations, :jedeclare_password, :string
		add_column :organizations, :alpha_jedeclare_password, :string
		add_column :organizations, :beta_jedeclare_password, :string

		#14. retrievers "Retriever"
		add_column :retrievers, :login, :string
		add_column :retrievers, :alpha_login, :string
		add_column :retrievers, :beta_login, :string
		add_column :retrievers, :alpha_password, :string
		add_column :retrievers, :beta_password, :string
		add_column :retrievers, :password, :string

		#5. sftps "Sftp"
		add_column :sftps, :host, :string
		add_column :sftps, :alpha_host, :string
		add_column :sftps, :beta_host, :string
		add_column :sftps, :login, :string
		add_column :sftps, :alpha_login, :string
		add_column :sftps, :beta_login, :string
		add_column :sftps, :password, :string
		add_column :sftps, :alpha_password, :string
		add_column :sftps, :beta_password, :string		
		add_column :sftps, :port, :string
		add_column :sftps, :alpha_port, :string
		add_column :sftps, :beta_port, :string

		#16. software_acds "Software::Acd"
		add_column :software_acds, :password, :string
		add_column :software_acds, :alpha_password, :string
		add_column :software_acds, :beta_password, :string

		#17. software_exact_online "Software::ExactOnline"
		add_column :software_exact_online, :client_id, :text
		add_column :software_exact_online, :alpha_client_id, :text
		add_column :software_exact_online, :beta_client_id, :text
		add_column :software_exact_online, :client_secret, :text
		add_column :software_exact_online, :alpha_client_secret, :text
		add_column :software_exact_online, :beta_client_secret, :text
		add_column :software_exact_online, :access_token, :text
		add_column :software_exact_online, :alpha_access_token, :text
		add_column :software_exact_online, :beta_access_token, :text
		add_column :software_exact_online, :refresh_token, :text
		add_column :software_exact_online, :alpha_refresh_token, :text
		add_column :software_exact_online, :beta_refresh_token, :text

		#18. software_ibizas "Software::Ibiza"
		add_column :software_ibizas, :access_token, :text
		add_column :software_ibizas, :alpha_access_token, :text
		add_column :software_ibizas, :beta_access_token, :text
		add_column :software_ibizas, :access_token_2, :text
		add_column :software_ibizas, :alpha_access_token_2, :text
		add_column :software_ibizas, :beta_access_token_2, :text

		#19. software_my_unisofts "Software::MyUnisoft"
		add_column :software_my_unisofts, :api_token, :text
		add_column :software_my_unisofts, :alpha_api_token, :text
		add_column :software_my_unisofts, :beta_api_token, :text

		#20. users "User"
		add_column :users, :password, :string
		add_column :users, :alpha_password, :string
		add_column :users, :beta_password, :string
	end
end
