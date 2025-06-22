import { defineType } from 'sanity'

export const taskEventTypes = defineType({
    name: 'taskEvent',
    title: 'Task Event',
    type: 'document',

    fields: [
        {
            name: 'employeeName',
            title: 'Employee Name',
            type: 'string',
            validation: (Rule) => Rule.required(),
        },
        {
            name: 'taskComplitionDate',
            title: 'Task Complition Date',
            type: 'datetime',
            initialValue: () => new Date().toISOString(),
            validation: (Rule) => Rule.required(),
        },
        {
            name: 'description',
            title: 'Description',
            type: 'string',
            validation: (Rule) => Rule.required(),
        },
        {
            name: 'locationLink',
            title: 'Location Link',
            type: 'string',

        },
        {
            name: 'employeeEmailId',
            title: 'Employee Email Id',
            type: 'string',

        },
        {
            name: 'mobileNumber',
            title: 'mobile Number',
            type: 'string',
            validation: (Rule) => Rule.required(),
        },
        {
            name: 'isTaskCompleted',
            title: 'Is Task Completed',
            type: 'boolean',
            initialValue: false,

            options: {
                layout: 'checkbox',
            },
        }
    ],
})
