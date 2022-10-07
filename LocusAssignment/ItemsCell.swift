//
//  ItemsCell.swift
//  LocusAssignment
//
//  Created by Sumit Gupta on 08/10/22.
//

import Foundation
import UIKit


protocol ISupportApplyingState {
    func applyState(fromModel formModel: NSMutableDictionary)
}

/*
 Base Cell for each cell type
 */
public class BaseItemCell: UITableViewCell, ISupportApplyingState {
    fileprivate var itemModel: ItemModel
    fileprivate var formModel: NSMutableDictionary
    
    init(withItemModel: ItemModel, withFormModel: NSMutableDictionary, withReuseIdentifier reuseIdentifier: String) {
        self.itemModel = withItemModel
        self.formModel = withFormModel
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyState(fromModel formModel: NSMutableDictionary) {
        // Do nothing here, override it
        print("BaseItemCell: applyState: executed it should be overridden")
    }
}


public class ImageCell: BaseItemCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static let CELL_ID = "ImageCell"
    
    private var title = UILabel()
    private var imageButton = UIButton()
    private var removeButton = UIButton()
    private weak var parentVC: UIViewController?
    
    init(withItem item: ItemModel, withFormModel: NSMutableDictionary, withParentVC: UIViewController) {
        self.parentVC = withParentVC
        super.init(withItemModel: item, withFormModel: withFormModel, withReuseIdentifier: ImageCell.CELL_ID)
        selectionStyle = .none
        
        title.text = item.title
        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(title)
        title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        title.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8).isActive = true
        
        imageButton.backgroundColor = .lightGray
        imageButton.addTarget(self, action: #selector(imageBtnClicked), for: .touchUpInside)
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageButton)
        imageButton.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 16).isActive = true
        imageButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
        imageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        imageButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        imageButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        
        removeButton.addTarget(self, action: #selector(removeClicked), for: .touchUpInside)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(removeButton)
        removeButton.centerXAnchor.constraint(equalTo: imageButton.trailingAnchor).isActive = true
        removeButton.centerYAnchor.constraint(equalTo: imageButton.topAnchor).isActive = true
        removeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        removeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        removeButton.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        removeButton.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func imageBtnClicked() {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let alertController = UIAlertController(title: nil, message: "Device has no camera.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Alright", style: .default, handler: { alert in
            })
            alertController.addAction(okAction)
            parentVC?.present(alertController, animated: true)
        } else {
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.sourceType = .photoLibrary
            imgPicker.allowsEditing = false
            parentVC?.present(imgPicker, animated: true)
        }
    }
    
    @objc private func removeClicked() {
        self.imageButton.setBackgroundImage(nil, for: .normal)
        self.formModel.removeObject(forKey: itemModel.id)
        self.removeButton.isHidden = true
    }
    
    // MARK: - Overridden functions
    
    override func applyState(fromModel formModel: NSMutableDictionary) {
        if let img = formModel[itemModel.id] as? UIImage {
            self.imageButton.setBackgroundImage(img, for: .normal)
            self.removeButton.isHidden = false
        }
    }
    
    //MARK: - UINavigationControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey :
    Any]) {
        if let img = info[.originalImage] as? UIImage {
            self.imageButton.setBackgroundImage(img, for: .normal)
            self.removeButton.isHidden = false
            parentVC?.dismiss(animated: true, completion: nil)
            self.formModel.setValue(img, forKey: itemModel.id)
       }
        else {
            print("error capturing image")
       }
    }
}


class SingleChoiceButtonsCell: BaseItemCell {
    static let CELL_ID = "SingleChoiceButtonsCell"
    
    private var title = UILabel()
    private var radioButtonArray: [RadioButton] = []
    
    init(withItem item: ItemModel, withFormModel: NSMutableDictionary) {
        super.init(withItemModel: item, withFormModel: withFormModel, withReuseIdentifier: SingleChoiceButtonsCell.CELL_ID)
        selectionStyle = .none
        
        title.text = item.title
        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(title)
        title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        title.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8).isActive = true
        
        var otherButtonsArray: [RadioButton] = []
        var topViewToUse: UIView = title
        for btnString in item.dataMap.options ?? [] {
            let radioBtn = RadioButton(type: .custom)
            radioButtonArray.append(radioBtn)
            radioBtn.iconColor = .black
            radioBtn.indicatorColor = .black
            radioBtn.setTitleColor(.black, for: .normal)
            radioBtn.translatesAutoresizingMaskIntoConstraints = false
            radioBtn.setTitle(btnString, for: .normal)
            radioBtn.addTarget(self, action: #selector(btnPressed), for: .touchUpInside)
            contentView.addSubview(radioBtn)
            radioBtn.topAnchor.constraint(equalTo: topViewToUse.bottomAnchor, constant: 8).isActive = true
            radioBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            radioBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
            
            for btn in otherButtonsArray {
                radioBtn.otherButtons.append(btn)
            }
            
            topViewToUse = radioBtn
            otherButtonsArray.append(radioBtn)
        }
        topViewToUse.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        
        applyState(fromModel: formModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private functions
    
    @objc private func btnPressed(_ btn: UIButton) {
        if let title = btn.currentTitle {
            self.formModel.setValue(title, forKey: itemModel.id)
        }
    }
    
    //MARK: - Overridden functions
    
    override func applyState(fromModel formModel: NSMutableDictionary) {
        if let selectedButtonTitle = formModel[itemModel.id] as? String {
            for btn in radioButtonArray {
                if btn.titleLabel?.text == selectedButtonTitle {
                    btn.isSelected = true
                }
            }
        }
    }
}


class CommentsCell: BaseItemCell, UITextViewDelegate {
    static let CELL_ID = "CommentsCell"
    
    private var title = UILabel()
    private var switchBtn = UISwitch()
    private var commentTextView: UITextView?
    private var contentViewBottomConstraint: NSLayoutConstraint?
    private weak var tableView: UITableView?
    
    init(withItem item: ItemModel, withFormModel: NSMutableDictionary, withParentTable tableView: UITableView) {
        self.tableView = tableView
        super.init(withItemModel: item, withFormModel: withFormModel, withReuseIdentifier: CommentsCell.CELL_ID)
        
        selectionStyle = .none
        clipsToBounds = true
        
        title.text = item.title
        title.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(title)
        title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        title.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8).isActive = true
        
        switchBtn.addTarget(self, action: #selector(switchPressed), for: .touchUpInside)
        switchBtn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(switchBtn)
        switchBtn.centerYAnchor.constraint(equalTo: title.centerYAnchor).isActive = true
        switchBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        title.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8).isActive = true
        let bottomConstraint = title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        self.contentViewBottomConstraint = bottomConstraint
        bottomConstraint.isActive = true
        
        applyState(fromModel: formModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func switchPressed(withoutTableReload: Bool = false) {
        if !withoutTableReload {
            self.formModel.setValue("", forKey: itemModel.id)
        }
        if switchBtn.isOn {
            if commentTextView != nil {
                return
            }
            let commentTextView = UITextView()
            self.commentTextView = commentTextView
            commentTextView.delegate = self
            commentTextView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.7)
            commentTextView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(commentTextView)
            commentTextView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 16).isActive = true
            commentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            commentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            commentTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            self.contentViewBottomConstraint?.isActive = false
            let cons = commentTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            self.contentViewBottomConstraint = cons
        }
        else {
            self.formModel.removeObject(forKey: itemModel.id)
            self.contentViewBottomConstraint?.isActive = false
            self.commentTextView?.removeFromSuperview()
            self.commentTextView = nil
            let bottomConstraint = title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
            self.contentViewBottomConstraint = bottomConstraint
            bottomConstraint.isActive = true
        }
        if !withoutTableReload {
            tableView?.reloadData()
        }
    }
    
    //MARK: - Overridden functions
    
    override func applyState(fromModel formModel: NSMutableDictionary) {
        if let commentText = formModel[itemModel.id] as? String {
            self.switchBtn.setOn(true, animated: false)
            switchPressed(withoutTableReload: true)
            self.commentTextView?.text = commentText
            self.contentViewBottomConstraint?.isActive = true
        }
    }
    
    //MARK: - UITextViewDelegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.formModel.setValue(textView.text, forKey: itemModel.id)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.formModel.setValue(textView.text, forKey: itemModel.id)
    }
}
