import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import ConfirmModalController from "../controllers/confirm_modal_controller"
import TmdbSearchController from "../controllers/tmdb_search_controller"
import FilterController from "../controllers/filter_controller"
import AddToPlaylistController from "../controllers/add_to_playlist_controller"
import PrivacyNoticeController from "../controllers/privacy_notice_controller"
import ToastController from "../controllers/toast_controller"
import SideMenuController from "../controllers/side_menu_controller"

const application = Application.start()
application.register("confirm-modal", ConfirmModalController)
application.register("tmdb-search", TmdbSearchController)
application.register("filter", FilterController)
application.register("add-to-playlist", AddToPlaylistController)
application.register("privacy-notice", PrivacyNoticeController)
application.register("toast", ToastController)
application.register("side-menu", SideMenuController)
