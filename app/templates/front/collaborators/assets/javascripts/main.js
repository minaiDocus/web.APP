class Collaborator{
  constructor () {
    this.applicationJS = new ApplicationJS;
    this.collaborator_modal = $('#add-edit-collaborator.modal');
    this.member_group_modal = $('#edit-group.modal');
    this.organization_id = $('input:hidden[name="organization_id"]').val();
  }

  get_collaborator_view(params){
    this.applicationJS.parseAjaxResponse(params).then((element)=>{
      this.collaborator_modal.find('.modal-content').html($(element).find('.modal-content').html());
      $('#select-collaborator-role').removeClass('form-control');
      $('#select-organization-group-list').removeClass('form-control');
      $('#select-collaborator-role').searchableOptionList();
      $('#select-organization-group-list').searchableOptionList();
      this.collaborator_modal.modal('show');
    });
  }

  get_group_view(params){
    this.applicationJS.parseAjaxResponse(params).then((element)=>{
      this.member_group_modal.find('.modal-content').html($(element).find('.modal-content').html());
      $('#select-collaborators-list').removeClass('form-control');
      $('#select-customers-collaborators-list').removeClass('form-control');
      $('#select-collaborators-list').searchableOptionList();
      $('#select-customers-collaborators-list').searchableOptionList();
      this.member_group_modal.modal('show');
    });
  }

  add(target){
    let params =  { 'url': '/organizations/' + this.organization_id + '/' + target + '/new' };

    if (target == 'collaborators') {
      this.get_collaborator_view(params);
    }
    else if (target == 'groups') {
      this.get_group_view(params);
    }
  }

  edit(target, id){
    let params =  { 'url': '/organizations/' + this.organization_id + '/' + target + '/' + id + '/edit' };

    if (target == 'collaborators') {
      this.get_collaborator_view(params);
    }
    else if (target == 'groups') {
      this.get_group_view(params);
    }
  }


  load_per_page(per_page) {
    let self = this;
    let params =  {
      'url': '/organizations/' + this.organization_id + '/collaborators?per_page=' + per_page,
      'target': '.collaborators-content'
    };

    var after_update_content = function(){
      self.main();
      $('select.display option[value="' + per_page + '"]').attr('selected','selected');
    };

    this.applicationJS.parseAjaxResponse(params, null, after_update_content);
  }

  main() {
    var self = this;

    $('.action.sub_edit_delete, .edit_group').unbind('click');
    $('.action.sub_edit_delete, .edit_group').bind('click',function(e) {
      e.stopPropagation();

      $('.sub_menu').not(this).each(function(){
        $(this).addClass('hide');
      });

      $(this).parent().find('.sub_menu').removeClass('hide');
    });

    $('.add-or-edit').unbind('click').bind('click', function(e) {
      e.stopPropagation();
      if ($(this).hasClass('member')) {
        if ($(this).hasClass('add-collaborator')) { self.add('collaborators'); }
        else if ($(this).hasClass('edit')) { self.edit('collaborators', $(this).parent().attr('id').split('-')[1]); }
      }
      else if ($(this).hasClass('member-group')) {
        if ($(this).hasClass('create-group')) { self.add('groups'); }
        else if ($(this).hasClass('edit')) { self.edit('groups', $(this).parent().attr('id').split('-')[1]); }

      }
    });

    $('select.display').on('change', function() {self.load_per_page($("option:selected", this).val());});

    self.hide_sub_menu();
  }

  hide_sub_menu() {
    $(document).click(function(e) {
      if ($('.sub_menu').is(':visible')) {
        $('.sub_menu').addClass('hide');
      }
    });
  }
}


jQuery(function() {
  var collaborator = new Collaborator();
  collaborator.main();
});