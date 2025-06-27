import { defineType } from 'sanity'

export const appImage = defineType({
    name: 'appImages',
    title: 'App Images',
    type: 'document',

    fields: [
        {
            name: 'imageName',
            title: 'Image Name',
            type: 'string',
            validation: (Rule) => Rule.required(),
        },
        {
            name: 'uploadImage',
            title: 'Upload Image',
            type: 'image',
            validation: (Rule) => Rule.required(),
        },


    ],
})
